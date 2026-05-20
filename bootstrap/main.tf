terraform {
  required_version = ">= 1.7.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

data "aws_ssm_parameter" "rds_master_password" {
  name = var.rds_master_password_ssm_name
}

data "aws_kms_key" "ssm" {
  key_id = var.ssm_kms_key_id
}

module "github_actions_role" {
  source = "../modules/iam/github_actions_role"

  project                      = var.project
  name_prefix                  = var.name_prefix
  github_organization          = var.github_organization
  github_repository            = var.github_repository
  github_branch                = var.github_branch
  role_name                    = var.github_actions_role_name
  rds_master_password_ssm_name = var.rds_master_password_ssm_name
  ssm_kms_key_id               = var.ssm_kms_key_id
  github_oidc_thumbprints      = var.github_oidc_thumbprints
  state_bucket_name            = var.state_bucket_name
  lock_table_name              = var.lock_table_name
  ec2_role_arn                 = module.ec2_app_role.ec2_role_arn
  ansible_artifacts_bucket_name = var.ansible_artifacts_bucket_name
}

module "ec2_app_role" {
  source = "../modules/iam/ec2_app_role"

  name_prefix         = var.name_prefix
  ssm_db_password_arn = data.aws_ssm_parameter.rds_master_password.arn
  ssm_kms_key_arn     = data.aws_kms_key.ssm.arn
  ansible_artifacts_bucket_name = var.ansible_artifacts_bucket_name
}

module "ansible_artifacts_s3" {
  source = "../modules/s3_artifacts"

  ansible_artifacts_bucket_name = var.ansible_artifacts_bucket_name
}
