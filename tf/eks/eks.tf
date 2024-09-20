# EKS Cluster using the EKS module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.org}-${var.env}-eks-cluster"
  cluster_version = "1.30"

  # Subnets for control plane and worker nodes
  vpc_id                   = var.vpc_id
  subnet_ids               = concat(var.public_subnets, var.private_subnets)
  control_plane_subnet_ids = var.private_subnets

  # Cluster endpoint access configuration
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Enable Core EKS Add-ons
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  # Managed Node Groups
  eks_managed_node_groups = {
    frontend = {
      instance_types = ["m6g.large"]
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      subnet_ids     = var.public_subnets
      ami_type       = "AL2_ARM_64"
    }
    backend = {
      instance_types = ["m6g.large"]
      desired_size   = 1
      min_size       = 1
      max_size       = 2
      subnet_ids     = var.private_subnets
      ami_type       = "AL2_ARM_64"
    }
  }

  # Add the current user as cluster admin
  enable_cluster_creator_admin_permissions = true

  tags = merge(var.tags, {
    "Name" = "${var.org}-${var.env}-eks-cluster"
  })
}

# Security Group for EKS Nodes
module "eks_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.org}-${var.env}-eks-sg"
  description = "Security Group for EKS"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS traffic to the Kubernetes API"
      cidr_blocks = var.local_ip
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS traffic to the frontend"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic to the frontend"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = var.tags
}