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
  description = "Deployment environment name such as dev, stg, or prod"
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Prefix used for resource naming"
  type        = string
  default     = "AwsStudy"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_1a_cidr" {
  description = "CIDR block for the public subnet in the first availability zone"
  type        = string
}

variable "public_subnet_1c_cidr" {
  description = "CIDR block for the public subnet in the second availability zone"
  type        = string
}

variable "private_subnet_1a_cidr" {
  description = "CIDR block for the private subnet in the first availability zone"
  type        = string
}

variable "private_subnet_1c_cidr" {
  description = "CIDR block for the private subnet in the second availability zone"
  type        = string
}

variable "cidr_ip_from_internet" {
  description = "CIDR block allowed to access the ALB from the internet"
  type        = string
}

variable "ami" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}

variable "alarm_email" {
  description = "Email address subscribed to SNS alarm notifications"
  type        = string
}

variable "db_master_username" {
  description = "Master username for the RDS instance"
  type        = string
  default     = "admin"
}

variable "rds_master_password_ssm_name" {
  description = "SSM Parameter Store name that stores the RDS master password"
  type        = string
  default     = "/rds/master/password"
}
