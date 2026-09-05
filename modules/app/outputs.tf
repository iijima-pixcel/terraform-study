output "alarm_notification_topic_arn" {
  description = "ARN of the SNS topic used for CloudWatch alarm notifications"
  value       = aws_sns_topic.alarm.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "ec2_instance_ids" {
  description = "IDs of the EC2 instances created by this module"

  value = {
    for az, instance in aws_instance.app :
    az => instance.id
  }
}

output "rds_endpoint" {
  description = "Endpoint address of the RDS instance"
  value       = aws_db_instance.this.address
}

output "alb_type" {
  description = "Type of the Application Load Balancer"
  value       = aws_lb.this.load_balancer_type
}

output "alb_internal" {
  description = "Whether the ALB is internal"
  value       = aws_lb.this.internal
}

output "target_group_port" {
  description = "Port of the target group"
  value       = aws_lb_target_group.this.port
}

output "target_group_protocol" {
  description = "Protocol of the target group"
  value       = aws_lb_target_group.this.protocol
}

output "target_group_target_type" {
  description = "Target type of the target group"
  value       = aws_lb_target_group.this.target_type
}

output "listener_port" {
  description = "Port of the ALB listener"
  value       = aws_lb_listener.http.port
}

output "listener_protocol" {
  description = "Protocol of the ALB listener"
  value       = aws_lb_listener.http.protocol
}

output "listener_default_action_type" {
  description = "Default action type of the ALB listener"
  value       = aws_lb_listener.http.default_action[0].type
}

output "ec2_instance_types" {
  description = "Instance types of the EC2 instances"

  value = {
    for az, instance in aws_instance.app :
    az => instance.instance_type
  }
}

output "iam_instance_profile_name" {
  description = "IAM Instance Profile attached to the EC2 instances"
  value       = var.iam_instance_profile_name
}

output "ec2_has_public_ips" {
  description = "Whether the EC2 instances are configured with public IPs"

  value = {
    for az, instance in aws_instance.app :
    az => instance.associate_public_ip_address
  }
}

output "ec2_private_ips" {
  description = "Private IP addresses of the EC2 instances"

  value = {
    for az, instance in aws_instance.app :
    az => instance.private_ip
  }
}

output "rds_instance_class" {
  description = "Instance class of the RDS instance"
  value       = aws_db_instance.this.instance_class
}

output "rds_engine" {
  description = "Engine of the RDS instance"
  value       = aws_db_instance.this.engine
}

output "rds_publicly_accessible" {
  description = "Whether the RDS instance is publicly accessible"
  value       = aws_db_instance.this.publicly_accessible
}

output "rds_backup_retention_period" {
  description = "Backup retention period of the RDS instance"
  value       = aws_db_instance.this.backup_retention_period
}

output "sns_subscription_protocol" {
  description = "Protocol of the SNS subscription"
  value       = aws_sns_topic_subscription.alarm_email.protocol
}

output "ec2_high_cpu_alarm_names" {
  value = {
    for key, alarm in aws_cloudwatch_metric_alarm.ec2_high_cpu :
    key => alarm.alarm_name
  }
}

output "ec2_status_check_failed_alarm_names" {
  value = {
    for key, alarm in aws_cloudwatch_metric_alarm.ec2_status_check_failed :
    key => alarm.alarm_name
  } 
}

output "alb_5xx_metric_name" {
  description = "Metric name of the ALB 5xx alarm"
  value       = aws_cloudwatch_metric_alarm.alb_5xx.metric_name
}

output "rds_low_storage_metric_name" {
  description = "Metric name of the RDS low storage alarm"
  value       = aws_cloudwatch_metric_alarm.rds_low_storage.metric_name
}

output "rds_db_name" {
  description = "Database name of the RDS instance"
  value       = aws_db_instance.this.db_name
}

output "rds_username" {
  description = "Master username of the RDS instance"
  value       = aws_db_instance.this.username
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.this.arn
}
