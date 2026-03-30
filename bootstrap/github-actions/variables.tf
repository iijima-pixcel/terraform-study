variable "region" {
  description = "AWS region for resource deployment"
  type        = string
  default     = "ap-northeast-1"
}

variable "project" {
  description = "Project name used for common resource tags"
  type        = string
  default     = "AwsStudy"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "bootstrap"
}

variable "name_prefix" {
  description = "Prefix used for resource naming"
  type        = string
  default     = "AwsStudy"
}

variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch name"
  type        = string
  default     = "main"
}

variable "github_actions_role_name" {
  description = "IAM role name for GitHub Actions"
  type        = string
  default     = "GithubActionsTerraformRole"
}

variable "rds_master_password_ssm_name" {
  description = "SSM Parameter Store name that stores the RDS master password"
  type        = string
  default     = "/rds/master/password"
}

variable "ssm_kms_key_id" {
  description = "KMS key ID or alias for SSM SecureString"
  type        = string
}

variable "github_oidc_thumbprints" {
  description = "Thumbprints for GitHub OIDC provider"
  type        = list(string)
}
