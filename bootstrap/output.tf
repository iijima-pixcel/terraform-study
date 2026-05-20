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
  value       = module.ec2_app_role.instance_profile_name
}

output "state_bucket_name" {
  description = "S3 bucket name for Terraform state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking"
  value       = aws_dynamodb_table.terraform_lock.name
}

output "ec2_instance_profile_arn" {
  description = "EC2 instance profile ARN"
  value       = module.ec2_app_role.instance_profile_arn
}

output "ec2_role_name" {
  description = "EC2 IAM role name"
  value       = module.ec2_app_role.ec2_role_name
}

output "ec2_role_arn" {
  description = "EC2 IAM role ARN"
  value       = module.ec2_app_role.ec2_role_arn
}
