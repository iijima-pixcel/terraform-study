output "github_actions_role_arn" {
  description = "ARN of GitHub Actions Terraform execution role"
  value       = module.github_actions_role.role_arn
}

output "github_actions_role_name" {
  description = "Name of GitHub Actions Terraform execution role"
  value       = module.github_actions_role.role_name
}

output "ec2_instance_profile_name" {
  description = "EC2 instance profile name"
  value       = module.github_actions_role.ec2_instance_profile_name
}
