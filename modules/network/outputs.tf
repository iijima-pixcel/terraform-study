output "aws_study_vpc_id" {
  value = aws_vpc.this.id
}

output "aws_study_public_subnet_1a_id" {
  value = aws_subnet.public_1a.id
}

output "aws_study_public_subnet_1c_id" {
  value = aws_subnet.public_1c.id
}

output "aws_study_private_subnet_1a_id" {
  value = aws_subnet.private_1a.id
}

output "aws_study_private_subnet_1c_id" {
  value = aws_subnet.private_1c.id
}
