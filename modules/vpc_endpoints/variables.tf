variable "name_prefix" {
  description = "Name prefix"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for VPC endpoints"
  type        = list(string)
}

variable "ssm_vpc_endpoint_sg_id" {
  description = "Security Group ID attached to SSM VPC endpoints"
  type        = string
}
