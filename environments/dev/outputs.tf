output "github_actions_role_arn" {
  description = "ARN of GitHub Actions Terraform execution role"
  value       = module.github_actions_role.role_arn
}
