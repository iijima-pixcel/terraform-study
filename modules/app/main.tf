# SSM SecureString (RDS password)
data "aws_ssm_parameter" "rds_master_password" {
  name            = var.rds_master_password_ssm_name
  with_decryption = true
}

# ALB
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

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# EC2
resource "aws_instance" "app" {
  ami                         = var.ami
  instance_type               = "t3.micro"
  key_name                    = var.key_name
  subnet_id                   = var.public_subnet_1a_id
  vpc_security_group_ids      = [var.ec2_security_group_id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.name_prefix}EC2"
  }
}

# TargetGroup
resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.app.id
  port             = 8080
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

# RDS (MySQL)
resource "aws_db_instance" "this" {
  identifier              = var.rds_identifier
  db_name                 = var.rds_db_name
  allocated_storage       = 20
  instance_class          = "db.t3.micro"
  engine                  = "mysql"
  username                = var.db_master_username
  password                = data.aws_ssm_parameter.rds_master_password.value
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.rds_security_group_id]
  backup_retention_period = 7
  publicly_accessible     = false
  multi_az                = false
  skip_final_snapshot     = false
  final_snapshot_identifier = lower(
    "${var.rds_identifier}-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  )

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

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "ec2_status_check_failed" {
  alarm_name        = "${var.name_prefix}-Ec2StatusCheckFailed"
  alarm_description = "EC2 インスタンスのステータスチェック（システム/インスタンス）が失敗した場合に通知。"

  namespace           = "AWS/EC2"
  metric_name         = "StatusCheckFailed"
  statistic           = "Maximum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 0
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "ignore"

  dimensions = {
    InstanceId = aws_instance.app.id
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  tags = {
    Name = "${var.name_prefix}Ec2StatusCheckFailedAlarm"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_high_cpu" {
  alarm_name        = "${var.name_prefix}-Ec2HighCpu"
  alarm_description = "EC2 インスタンスの CPUUtilization が 80% を 15 分間超えた場合に通知。"

  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 3
  threshold           = 80
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"

  dimensions = {
    InstanceId = aws_instance.app.id
  }

  alarm_actions = [aws_sns_topic.alarm.arn]
  tags = {
    Name = "${var.name_prefix}CpuHighAlarm"
  }
}

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

  # CloudFormation と同じ dimensions
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
