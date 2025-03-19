variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet in AZ1"
  type        = string
}

variable "public_subnet_cidr_2" {
  description = "CIDR block for the public subnet in AZ2"
  type        = string
}

variable "availability_zone_1" {
  description = "First Availability Zone for public subnet"
  type        = string
}

variable "availability_zone_2" {
  description = "Second Availability Zone for public subnet"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}
