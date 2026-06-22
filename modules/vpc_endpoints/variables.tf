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

variable "private_route_table_ids" {
  description = "Private route table for S3 endpoint"
  type        = list(string)
}
