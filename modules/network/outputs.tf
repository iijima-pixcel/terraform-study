output "aws_study_vpc_id" {
  description = "ID of the VPC created by the network module"
  value       = aws_vpc.this.id
}

output "aws_study_public_subnet_1a_id" {
  description = "ID of the public subnet in the first availability zone"
  value       = aws_subnet.public_1a.id
}

output "aws_study_public_subnet_1c_id" {
  description = "ID of the public subnet in the second availability zone"
  value       = aws_subnet.public_1c.id
}

output "aws_study_private_subnet_1a_id" {
  description = "ID of the private subnet in the first availability zone"
  value       = aws_subnet.private_1a.id
}

output "aws_study_private_subnet_1c_id" {
  description = "ID of the private subnet in the second availability zone"
  value       = aws_subnet.private_1c.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_1a_cidr" {
  description = "CIDR block of the public subnet in AZ 1a"
  value       = aws_subnet.public_1a.cidr_block
}

output "public_subnet_1c_cidr" {
  description = "CIDR block of the public subnet in AZ 1c"
  value       = aws_subnet.public_1c.cidr_block
}

output "private_subnet_1a_cidr" {
  description = "CIDR block of the private subnet in AZ 1a"
  value       = aws_subnet.private_1a.cidr_block
}

output "private_subnet_1c_cidr" {
  description = "CIDR block of the private subnet in AZ 1c"
  value       = aws_subnet.private_1c.cidr_block
}

output "vpc_name" {
  description = "Name tag of the VPC"
  value       = aws_vpc.this.tags.Name
}
