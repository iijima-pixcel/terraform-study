output "role_name" {
  description = "Name of the GitHub Actions Terraform execution role"
  value       = aws_iam_role.github_actions_terraform.name
}

output "role_arn" {
  description = "ARN of the GitHub Actions Terraform execution role"
  value       = aws_iam_role.github_actions_terraform.arn
}

output "policy_arn" {
  description = "ARN of the IAM policy attached to the GitHub Actions role"
  value       = aws_iam_policy.github_actions_terraform.arn
}

output "ec2_role_arn" {
  description = "ARN of the EC2 role"
  value       = aws_iam_role.ec2.arn
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = aws_iam_instance_profile.ec2.name
}
