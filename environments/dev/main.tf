terraform {
  required_version = ">= 1.6"
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

module "network" {
  source      = "../../modules/network"
  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr

  public_subnet_1a_cidr  = var.public_subnet_1a_cidr
  public_subnet_1c_cidr  = var.public_subnet_1c_cidr
  private_subnet_1a_cidr = var.private_subnet_1a_cidr
  private_subnet_1c_cidr = var.private_subnet_1c_cidr
}

module "security" {
  source                = "../../modules/security"
  name_prefix           = var.name_prefix
  vpc_id                = module.network.aws_study_vpc_id
  cidr_ip_from_internet = var.cidr_ip_from_internet
}

module "app" {
  source      = "../../modules/app"
  name_prefix = var.name_prefix

  ami         = var.ami
  key_name    = var.key_name
  alarm_email = var.alarm_email

  db_master_username           = var.db_master_username
  rds_master_password_ssm_name = var.rds_master_password_ssm_name

  vpc_id               = module.network.aws_study_vpc_id
  public_subnet_1a_id  = module.network.aws_study_public_subnet_1a_id
  public_subnet_1c_id  = module.network.aws_study_public_subnet_1c_id
  private_subnet_1a_id = module.network.aws_study_private_subnet_1a_id
  private_subnet_1c_id = module.network.aws_study_private_subnet_1c_id

  alb_security_group_id = module.security.alb_security_group_id
  ec2_security_group_id = module.security.ec2_security_group_id
  rds_security_group_id = module.security.rds_security_group_id
}
