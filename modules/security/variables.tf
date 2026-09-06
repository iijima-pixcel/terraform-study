variable "vpc_id" {
  description = "VPC ID where the security resources will be created"
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for naming security resources"
  type        = string
}
