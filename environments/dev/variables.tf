variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "project" {
  type    = string
  default = "AwsStudy"
}

variable "name_prefix" {
  type    = string
  default = "AwsStudy"
}

variable "vpc_cidr" {
  type = string
}

variable "public_subnet_1a_cidr" {
  type = string
}

variable "public_subnet_1c_cidr" {
  type = string
}

variable "private_subnet_1a_cidr" {
  type = string
}

variable "private_subnet_1c_cidr" {
  type = string
}

variable "cidr_ip_from_internet" {
  type = string
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

variable "db_master_username" {
  type    = string
  default = "admin"
}

variable "rds_master_password_ssm_name" {
  type    = string
  default = "/rds/master/password"
}
