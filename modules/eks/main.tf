# Fetch the latest Amazon Linux 2 EKS optimized AMI for your Kubernetes version using SSM
data "aws_ssm_parameter" "eks_worker_ami" {
  name = "/aws/service/eks/optimized-ami/1.31/amazon-linux-2/recommended/image_id"
}

# Create a launch template that uses the provided key pair and includes the bootstrap.sh script for Amazon Linux 2.
resource "aws_launch_template" "node_group_lt" {
  name_prefix   = "${var.cluster_name}-node-"
  image_id      = data.aws_ssm_parameter.eks_worker_ami.value
  instance_type = "t3.medium"  # Adjust as needed.
  key_name      = var.key_name

  # Use the bootstrap.sh script for Amazon Linux 2
  user_data = base64encode(<<EOF
#!/bin/bash
/etc/eks/bootstrap.sh ${var.cluster_name}
EOF
  )

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp2"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create the EKS cluster with Kubernetes version 1.31.
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.eks_role_arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  # Specify Kubernetes version 1.31
  version = "1.31"

  # Timeout for cluster creation (increased for stability)
  timeouts {
    create = "10m"
  }
}

# Create the EKS node group using the launch template.
resource "aws_eks_node_group" "this" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = var.node_instance_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  launch_template {
    id      = aws_launch_template.node_group_lt.id
    version = aws_launch_template.node_group_lt.latest_version  # Use latest launch template version dynamically
  }

  timeouts {
    create = "20m"
  }

  depends_on = [
    aws_eks_cluster.this
  ]
}
