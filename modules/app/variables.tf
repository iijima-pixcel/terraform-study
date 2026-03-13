variable "name_prefix" {
  description = "Prefix used for naming AWS resources"
  type        = string
}

# CloudFormation Parameters
variable "db_master_username" {
  description = "Master username for the RDS database"
  type        = string
  default     = "admin"
}

variable "ami" {
  description = "AMI ID used for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair used for SSH access"
  type        = string
}

variable "alarm_email" {
  description = "Email address to receive CloudWatch alarm notifications"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the application resources will be deployed"
  type        = string
}

variable "public_subnet_1a_id" {
  description = "ID of the public subnet in Availability Zone 1a"
  type        = string
}

variable "public_subnet_1c_id" {
  description = "ID of the public subnet in Availability Zone 1c"
  type        = string
}

variable "private_subnet_1a_id" {
  description = "ID of the private subnet in Availability Zone 1a"
  type        = string
}

variable "private_subnet_1c_id" {
  description = "ID of the private subnet in Availability Zone 1c"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of the security group attached to the Application Load Balancer"
  type        = string
}

variable "ec2_security_group_id" {
  description = "ID of the security group attached to the EC2 instance"
  type        = string
}

variable "rds_security_group_id" {
  description = "ID of the security group attached to the RDS instance"
  type        = string
}

# SSM secure string name (CloudFormation: /rds/master/password)
variable "rds_master_password_ssm_name" {
  description = "SSM Parameter Store name containing the RDS master password (SecureString)"
  type        = string
  default     = "/rds/master/password"
}

# RDS identifiers
variable "rds_identifier" {
  description = "Identifier used for the RDS instance"
  type        = string
  default     = "aws-study-db"
}

variable "rds_db_name" {
  description = "Initial database name created in the RDS instance"
  type        = string
  default     = "awsstudy"
}
