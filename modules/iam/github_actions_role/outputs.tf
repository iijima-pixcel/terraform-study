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
