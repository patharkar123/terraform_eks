variable "cluster_name" {
  description = "Name of the EKS Cluster"
  type        = string
}

variable "eks_role_arn" {
  description = "IAM Role ARN for the EKS cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs to use for the EKS cluster"
  type        = list(string)
}

variable "node_instance_role_arn" {
  description = "IAM Role ARN for the worker nodes (node group)"
  type        = string
}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "key_name" {
  description = "EC2 Key Pair name for the node group (will be used in the launch template)"
  type        = string
}
