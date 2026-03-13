output "alb_security_group_id" {
  description = "ID of the security group for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "ec2_security_group_id" {
  description = "ID of the security group for the EC2 application server"
  value       = aws_security_group.ec2.id
}

output "rds_security_group_id" {
  description = "ID of the security group for the RDS instance"
  value       = aws_security_group.rds.id
}
