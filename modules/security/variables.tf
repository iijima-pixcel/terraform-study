variable "vpc_id" {
  description = "VPC ID (Network layer output)"
  type        = string
}

variable "cidr_ip_from_internet" {
  description = "CIDR IP range for allowing SSH from the internet"
  type        = string
  default     = "36.8.0.45/32"
}

variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
  default     = "AwsStudy"
}

variable "project" {
  description = "Project tag value"
  type        = string
  default     = "AwsStudy"
}
