# EKS Cluster using the EKS module
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.org}-${local.env}-eks-cluster"
  cluster_version = "1.28"

  # Subnets for control plane and worker nodes
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = concat(module.vpc.public_subnets, module.vpc.private_subnets)
  control_plane_subnet_ids = module.vpc.private_subnets

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
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      subnet_ids     = module.vpc.public_subnets
      ami_type       = "AL2_ARM_64"
    }
    backend = {
      instance_types = ["t4g.micro"]
      desired_size   = 2
      min_size       = 1
      max_size       = 3
      subnet_ids     = module.vpc.private_subnets
      ami_type       = "AL2_ARM_64"
    }
  }

  # Add the current user as cluster admin
  enable_cluster_creator_admin_permissions = true

  tags = merge(local.tags, {
    "Name" = "${local.org}-${local.env}-eks-cluster"
  })
}

# Security Group for EKS Nodes
module "eks_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.org}-${local.env}-eks-sg"
  description = "Security Group for EKS"
  vpc_id      = module.vpc.vpc_id

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

  tags = local.tags
}
