variable "project" {
  description = "Project name used for common resource tags"
  type        = string
  default     = "AwsStudy"
}

variable "name_prefix" {
  description = "Prefix used for resource naming"
  type        = string
  default     = "AwsStudy"
}

variable "role_name" {
  description = "IAM role name for GitHub Actions Terraform execution"
  type        = string
  default     = "GithubActionsTerraformRole"
}

variable "github_organization" {
  description = "GitHub organization or user name"
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name"
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to assume this role"
  type        = string
  default     = "main"
}

variable "rds_master_password_ssm_name" {
  description = "SSM parameter name containing the RDS master password"
  type        = string
  default     = "/rds/master/password"
}

variable "ssm_kms_key_id" {
  description = "Existing KMS key identifier for SSM SecureString. Example: alias/aws/ssm or a key ARN."
  type        = string
}

variable "github_oidc_thumbprints" {
  description = "Thumbprints for the GitHub OIDC provider"
  type        = list(string)
}
