variable "project" {
  type    = string
  default = "AwsStudy"
}

variable "name_prefix" {
  type    = string
  default = "AwsStudy"
}

# CloudFormation Parameters
variable "db_master_username" {
  type    = string
  default = "admin"
}

variable "ami" {
  type = string
}

variable "key_name" {
  type = string
}

variable "alarm_email" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_1a_id" {
  type = string
}

variable "public_subnet_1c_id" {
  type = string
}

variable "private_subnet_1a_id" {
  type = string
}

variable "private_subnet_1c_id" {
  type = string
}

variable "alb_security_group_id" {
  type = string
}

variable "ec2_security_group_id" {
  type = string
}

variable "rds_security_group_id" {
  type = string
}

# SSM secure string name (CloudFormation: /rds/master/password)
variable "rds_master_password_ssm_name" {
  type    = string
  default = "/rds/master/password"
}

# RDS identifiers
variable "rds_identifier" {
  type    = string
  default = "aws-study-db"
}

variable "rds_db_name" {
  type    = string
  default = "awsstudy"
}
