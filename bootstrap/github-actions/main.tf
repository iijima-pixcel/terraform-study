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

module "github_actions_role" {
  source = "../../modules/iam/github_actions_role"

  project                      = var.project
  name_prefix                  = var.name_prefix
  github_organization          = var.github_organization
  github_repository            = var.github_repository
  github_branch                = var.github_branch
  role_name                    = var.github_actions_role_name
  rds_master_password_ssm_name = var.rds_master_password_ssm_name
  ssm_kms_key_id               = var.ssm_kms_key_id
  github_oidc_thumbprints      = var.github_oidc_thumbprints
}

