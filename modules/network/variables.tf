variable "name_prefix" {
  description = "Prefix used for naming network resources"
  type        = string
  default     = "AwsStudy"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1a_cidr" {
  description = "CIDR block for the public subnet in the first availability zone"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_1c_cidr" {
  description = "CIDR block for the public subnet in the second availability zone"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1a_cidr" {
  description = "CIDR block for the private subnet in the first availability zone"
  type        = string
  default     = "10.0.11.0/24"
}

variable "private_subnet_1c_cidr" {
  description = "CIDR block for the private subnet in the second availability zone"
  type        = string
  default     = "10.0.12.0/24"
}
