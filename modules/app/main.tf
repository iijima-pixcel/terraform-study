# RDSパスワードをSSM Parameter Storeから取得
data "aws_ssm_parameter" "rds_master_password" {
  name            = var.rds_master_password_ssm_name
  with_decryption = true
}
# マルチAZに使用
locals {
  app_instances = {
    "1a" = var.private_subnet_1a_id
    "1c" = var.private_subnet_1c_id
  }
}

# Internet-facing ALB
resource "aws_lb" "this" {
  name               = "${var.name_prefix}ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = [var.public_subnet_1a_id, var.public_subnet_1c_id]

  tags = {
    Name = "${var.name_prefix}ALB"
  }
}

# ALBからEC2:8080へ転送
resource "aws_lb_target_group" "this" {
  name        = "${var.name_prefix}TargetGroup"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    path                = "/"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "${var.name_prefix}TargetGroup"
  }
}

# HTTP:80 Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# 一般的なWeb攻撃への基本対策としてAWS Managed Rulesを適用
resource "aws_wafv2_web_acl" "this" {
  name  = "${var.name_prefix}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.name_prefix}-common-rule"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-waf"
    sampled_requests_enabled   = true
  }
}

# WAFをALBに関連付け
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = aws_lb.this.arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# スケーリング用テンプレート
resource "aws_launch_template" "app" {
  name_prefix   = "${var.name_prefix}-app-"
  image_id      = var.ami
  instance_type = "t3.micro"

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.ec2_security_group_id]
  }

  # Launch Template の user_data は Base64 エンコードする
  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -eux

    if ! systemctl list-unit-files | grep -q amazon-ssm-agent; then
      if command -v dnf >/dev/null 2>&1; then
        dnf install -y amazon-ssm-agent
      elif command -v yum >/dev/null 2>&1; then
        yum install -y amazon-ssm-agent
      else
        echo "No supported package manager found for installing amazon-ssm-agent"
        exit 1
      fi
    fi

    systemctl enable amazon-ssm-agent
    systemctl restart amazon-ssm-agent
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name_prefix}EC2-ASG"
    }
  }
}

resource "aws_autoscaling_group" "app" {
  name = "${var.name_prefix}-app-asg"

  min_size         = 2
  desired_capacity = 2
  max_size         = 2

  # 1a / 1c のPrivate Subnet
  vpc_zone_identifier = values(local.app_instances)

  # ASGで作成したEC2をTarget Groupへ自動登録
  target_group_arns = [
    aws_lb_target_group.this.arn
  ]

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # 今はAnsibleで後からアプリを入れるためEC2ヘルスチェックにする
  health_check_type = "EC2"

  tag {
    key                 = "Role"
    value               = "app"
    propagate_at_launch = true
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "this" {
  name        = lower("${var.name_prefix}-db-subnet-group")
  description = "Subnets for AwsStudy RDS"
  subnet_ids  = [var.private_subnet_1a_id, var.private_subnet_1c_id]

  tags = {
    Name = "${var.name_prefix}DbSubnetGroup"
  }
}

# Private Subnetに配置するMySQL RDS
resource "aws_db_instance" "this" {
  identifier                = var.rds_identifier
  db_name                   = var.rds_db_name
  allocated_storage         = 20
  instance_class            = "db.t3.micro"
  engine                    = "mysql"
  username                  = var.db_master_username
  password                  = data.aws_ssm_parameter.rds_master_password.value
  db_subnet_group_name      = aws_db_subnet_group.this.name
  vpc_security_group_ids    = [var.rds_security_group_id]
  backup_retention_period   = 7
  publicly_accessible       = false
  multi_az                  = true
  skip_final_snapshot       = true
  final_snapshot_identifier = "${lower(var.name_prefix)}-db-final-snapshot"

  tags = {
    Name = "${var.name_prefix}RDS"
  }
}

# SNS Topic + Subscription (email)
resource "aws_sns_topic" "alarm" {
  name = "${var.name_prefix}-AlarmTopic"

  tags = {
    Name = "${var.name_prefix}-AlarmTopic"
  }
}

resource "aws_sns_topic_subscription" "alarm_email" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# ASG全体の平均CPU使用率を50%付近に維持
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.name_prefix}-cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}

# ALB UnHealthyHostCount監視
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_host" {
  alarm_name        = "${var.name_prefix}-AlbUnhealthyHost"
  alarm_description = "ALB ターゲットグループで UnHealthyHostCount が一定時間 1 以上のときに通知。回復時は OK 通知も送信。"

  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 3
  datapoints_to_alarm = 2
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
    TargetGroup  = aws_lb_target_group.this.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  ok_actions    = [aws_sns_topic.alarm.arn]
  tags = {
    Name = "${var.name_prefix}AlbUnHealthyHostAlarm"
  }
}

# ALB 5xxエラー監視
resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name        = "${var.name_prefix}-Alb5xxHigh"
  alarm_description = "ALB の ELB 5xx エラーが 5 分間で 10 回以上発生した場合に通知。"

  namespace           = "AWS/ApplicationELB"
  metric_name         = "HTTPCode_ELB_5XX_Count"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 10
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"

  dimensions = {
    LoadBalancer = aws_lb.this.arn_suffix
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  tags = {
    Name = "${var.name_prefix}Alb5xxAlarm"
  }
}

# RDS空き容量5GB未満
resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  alarm_name        = "${var.name_prefix}-RdsLowStorage"
  alarm_description = "RDS の FreeStorageSpace が 5GB 未満になった場合に通知。"

  namespace           = "AWS/RDS"
  metric_name         = "FreeStorageSpace"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5368709120
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "missing"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.this.id
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  tags = {
    Name = "${var.name_prefix}RdsLowStorageAlarm"
  }
}
