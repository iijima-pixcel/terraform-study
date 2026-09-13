output "role_name" {
  description = "Name of the GitHub Actions Terraform execution role"
  value       = aws_iam_role.github_actions_terraform.name
}

output "role_arn" {
  description = "ARN of the GitHub Actions Terraform execution role"
  value       = aws_iam_role.github_actions_terraform.arn
}
