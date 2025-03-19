provider "aws" {
  region = var.region
}

# 1. VPC Module (created first)
module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  public_subnet_cidr_2 = var.public_subnet_cidr_2
  availability_zone_1  = var.availability_zone_1
  availability_zone_2  = var.availability_zone_2
  vpc_name             = var.vpc_name
}

# 2. IAM Module (depends on VPC)
module "eks_iam" {
  source        = "./modules/iam"
  eks_role_name = var.eks_role_name
  depends_on    = [ module.vpc ]
}

# 3. Key Pair Creation (depends on IAM)
resource "tls_private_key" "eks_node_key" {
  algorithm = "RSA"
  rsa_bits  = 4096

  depends_on = [ module.eks_iam ]
}

resource "aws_key_pair" "eks_key" {
  key_name   = var.key_name
  public_key = tls_private_key.eks_node_key.public_key_openssh

  depends_on = [ tls_private_key.eks_node_key ]
}

resource "local_file" "eks_node_private_key" {
  content         = tls_private_key.eks_node_key.private_key_pem
  filename        = "${path.module}/manifest/${var.key_name}.pem"
  file_permission = "0400"

  depends_on = [ aws_key_pair.eks_key ]
}

# 4. EKS Module (depends on VPC, IAM, and Key Pair)
module "eks" {
  source                 = "./modules/eks"
  cluster_name           = var.cluster_name
  eks_role_arn           = module.eks_iam.eks_cluster_role_arn
  subnet_ids             = module.vpc.public_subnet_ids
  node_instance_role_arn = module.eks_iam.eks_cluster_role_arn
  desired_capacity       = var.desired_capacity
  max_size               = var.max_size
  min_size               = var.min_size
  key_name               = var.key_name

  depends_on = [
    module.vpc,
    module.eks_iam,
    local_file.eks_node_private_key
  ]
}
