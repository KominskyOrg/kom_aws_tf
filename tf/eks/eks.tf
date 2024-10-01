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
      instance_types = ["t4g.micro"]
      desired_size   = 1
      min_size       = 1
      max_size       = 4
      subnet_ids     = var.public_subnets
      ami_type       = "AL2_ARM_64"
      labels = {
        role = "frontend"
      }
    }
    backend = {
      instance_types = ["t4g.micro"]
      desired_size   = 1
      min_size       = 1
      max_size       = 4
      subnet_ids     = var.private_subnets
      ami_type       = "AL2_ARM_64"
      labels = {
        role = "backend"
      }
    }
  }

  # Add the current user as cluster admin
  enable_cluster_creator_admin_permissions = true

  tags = merge(var.tags, {
    "Name" = "${var.org}-${var.env}-eks-cluster"
  })
}
