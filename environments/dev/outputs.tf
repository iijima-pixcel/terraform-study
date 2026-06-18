output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.app.alb_dns_name
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance created by this module"
  value       = module.app.ec2_instance_id
}

output "rds_endpoint" {
  description = "Endpoint address of the RDS instance"
  value       = module.app.rds_endpoint
}

output "rds_db_name" {
  description = "Database name of RDS"
  value       = module.app.rds_db_name
}

output "rds_username" {
  description = "Master username for RDS"
  value       = module.app.rds_username
}

output "ec2_private_ip" {
  description = "Private IP address of EC2 instance"
  value       = module.app.ec2_private_ip
}

output "ec2_security_group_id" {
  description = "Security group ID for EC2"
  value       = module.security.ec2_security_group_id
}

output "alb_arn" {
  description = "ARN of ALB"
  value       = module.app.alb_arn
}

output "target_group_arn" {
  description = "ARN of target group"
  value       = module.app.target_group_arn
}

output "ec2_iam_instance_profile" {
  description = "IAM Instance Profile attached to the EC2 instance"
  value       = module.app.ec2_iam_instance_profile
}
