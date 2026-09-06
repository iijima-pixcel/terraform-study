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

data "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-EC2-Instance-Profile"
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
}

module "vpc_endpoints" {
  source = "../../modules/vpc_endpoints"

  name_prefix             = var.name_prefix
  region                  = var.region
  vpc_id                  = module.network.aws_study_vpc_id
  private_subnet_ids      = module.network.private_subnet_ids
  ssm_vpc_endpoint_sg_id  = module.security.ssm_vpc_endpoint_sg_id
  private_route_table_ids = module.network.private_route_table_ids
}

module "app" {
  source      = "../../modules/app"
  name_prefix = var.name_prefix

  ami         = var.ami
  alarm_email = var.alarm_email

  iam_instance_profile_name = data.aws_iam_instance_profile.ec2.name

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

resource "aws_cloudwatch_log_group" "ssm_run_command" {
  name              = "SSMRunCommandLogs"
  retention_in_days = 14

  tags = {
    Name = "SSMRunCommandLogs"
  }
}
