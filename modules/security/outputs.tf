output "alb_security_group_id" {
  description = "ID of the security group for the Application Load Balancer"
  value       = aws_security_group.alb.id
  sensitive = true
}

output "ec2_security_group_id" {
  description = "ID of the security group for the EC2 application server"
  value       = aws_security_group.ec2.id
  sensitive = true
}

output "rds_security_group_id" {
  description = "ID of the security group for the RDS instance"
  value       = aws_security_group.rds.id
  sensitive = true
}

output "alb_security_group_name" {
  description = "Name of the ALB security group"
  value       = aws_security_group.alb.name
}

output "ec2_security_group_name" {
  description = "Name of the EC2 security group"
  value       = aws_security_group.ec2.name
}

output "rds_security_group_name" {
  description = "Name of the RDS security group"
  value       = aws_security_group.rds.name
}

output "has_alb_http_rule" {
  description = "Whether the ALB security group allows HTTP from the internet"
  value = length([
    for rule in aws_security_group.alb.ingress : rule
    if rule.from_port == 80
    && rule.to_port == 80
    && rule.protocol == "tcp"
    && contains(rule.cidr_blocks, "0.0.0.0/0")
  ]) > 0
}

output "has_ec2_app_rule" {
  description = "Whether the EC2 security group allows app traffic from the ALB on port 8080"
  value = length([
    for rule in aws_security_group.ec2.ingress : rule
    if rule.from_port == 8080
    && rule.to_port == 8080
    && rule.protocol == "tcp"
  ]) > 0
}

output "has_ec2_ssh_rule" {
  description = "Whether the EC2 security group allows SSH from the specified CIDR"
  value = length([
    for rule in aws_security_group.ec2.ingress : rule
    if rule.from_port == 22
    && rule.to_port == 22
    && rule.protocol == "tcp"
    && contains(rule.cidr_blocks, var.cidr_ip_from_internet)
  ]) > 0
}

output "has_ec2_ssh_from_any" {
  description = "Whether EC2 security group allows SSH (22) from 0.0.0.0/0"
  value = length([
    for rule in aws_security_group.ec2.ingress :
    rule
    if rule.from_port == 22 &&
       rule.to_port == 22 &&
       contains(rule.cidr_blocks, "0.0.0.0/0")
  ]) > 0
}

output "has_rds_mysql_rule" {
  description = "Whether the RDS security group allows MySQL from EC2 on port 3306"
  value = length([
    for rule in aws_security_group.rds.ingress : rule
    if rule.from_port == 3306
    && rule.to_port == 3306
    && rule.protocol == "tcp"
  ]) > 0
}
