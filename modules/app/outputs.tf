output "alarm_notification_topic_arn" {
  description = "ARN of the SNS topic used for CloudWatch alarm notifications"
  value       = aws_sns_topic.alarm.arn
}

output "ec2_status_check_failed_alarm_arn" {
  description = "ARN of the CloudWatch alarm for EC2 status check failures"
  value       = aws_cloudwatch_metric_alarm.ec2_status_check_failed.arn
}

output "ec2_high_cpu_alarm_arn" {
  description = "ARN of the CloudWatch alarm for high EC2 CPU utilization"
  value       = aws_cloudwatch_metric_alarm.ec2_high_cpu.arn
}

output "alb_unhealthy_host_alarm_arn" {
  description = "ARN of the CloudWatch alarm for unhealthy ALB targets"
  value       = aws_cloudwatch_metric_alarm.alb_unhealthy_host.arn
}

output "alb_5xx_alarm_arn" {
  description = "ARN of the CloudWatch alarm for ALB 5xx errors"
  value       = aws_cloudwatch_metric_alarm.alb_5xx.arn
}

output "rds_low_storage_alarm_arn" {
  description = "ARN of the CloudWatch alarm for low RDS free storage space"
  value       = aws_cloudwatch_metric_alarm.rds_low_storage.arn
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.this.dns_name
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance created by this module"
  value       = aws_instance.app.id
}

output "rds_endpoint" {
  description = "Endpoint address of the RDS instance"
  value       = aws_db_instance.this.address
}
