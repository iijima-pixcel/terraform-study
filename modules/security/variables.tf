variable "vpc_id" {
  description = "VPC ID where the security resources will be created"
  type        = string
}

variable "cidr_ip_from_internet" {
  description = "CIDR block allowed to access the EC2 instance via SSH"
  type        = string
  default     = "36.8.0.45/32"
}

variable "name_prefix" {
  description = "Prefix used for naming security resources"
  type        = string
}
