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

output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}
