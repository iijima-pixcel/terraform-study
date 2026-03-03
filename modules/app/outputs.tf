output "alarm_notification_topic_arn" {
  description = "CloudWatch アラーム通知先 SNS トピックの ARN"
  value       = aws_sns_topic.alarm.arn
}

output "ec2_status_check_failed_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.ec2_status_check_failed.arn
}

output "ec2_high_cpu_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.ec2_high_cpu.arn
}

output "alb_unhealthy_host_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.alb_unhealthy_host.arn
}

output "alb_5xx_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.alb_5xx.arn
}

output "rds_low_storage_alarm_arn" {
  value = aws_cloudwatch_metric_alarm.rds_low_storage.arn
}

output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "ec2_instance_id" {
  value = aws_instance.app.id
}

output "rds_endpoint" {
  value = aws_db_instance.this.address
}
