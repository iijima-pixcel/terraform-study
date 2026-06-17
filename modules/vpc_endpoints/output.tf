output "ssm_vpc_endpoint_id" {
  description = "VPC Endpoint ID for Systems Manager"
  value       = aws_vpc_endpoint.ssm.id
}

output "ssmmessages_vpc_endpoint_id" {
  description = "VPC Endpoint ID for SSM Messages"
  value       = aws_vpc_endpoint.ssmmessages.id
}

output "ec2messages_vpc_endpoint_id" {
  description = "VPC Endpoint ID for EC2 Messages"
  value       = aws_vpc_endpoint.ec2messages.id
}
