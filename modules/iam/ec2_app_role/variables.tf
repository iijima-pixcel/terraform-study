variable "name_prefix" {
  description = "Prefix used for IAM resource names"
  type        = string
}

variable "ssm_db_password_arn" {
  description = "ARN of the SSM parameter storing the DB password"
  type        = string
}

variable "ssm_kms_key_arn" {
  description = "ARN of the KMS key used to decrypt the SecureString parameter"
  type        = string
}

variable "ansible_artifacts_bucket_name" {
  description = "Ansible artifacts bucket name for s3"
  type        = string
}
