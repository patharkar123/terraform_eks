variable "region" {
  description = "AWS Region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

# VPC variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet in AZ1"
  type        = string
  default     = "10.0.101.0/24"
}

variable "public_subnet_cidr_2" {
  description = "CIDR block for the public subnet in AZ2"
  type        = string
  default     = "10.0.102.0/24"
}

variable "availability_zone_1" {
  description = "First Availability Zone"
  type        = string
  default     = "eu-west-1a"
}

variable "availability_zone_2" {
  description = "Second Availability Zone"
  type        = string
  default     = "eu-west-1b"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "my-vpc"
}

# IAM variables
variable "eks_role_name" {
  description = "Name of the EKS cluster IAM role"
  type        = string
  default     = "eks-cluster-role"
}

# EKS cluster variables
variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

# Key Pair variable
variable "key_name" {
  description = "Name for the EC2 key pair to attach to EKS nodes"
  type        = string
  default     = "eks-node-key"
}
