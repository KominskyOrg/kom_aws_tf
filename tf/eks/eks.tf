module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.org}-${local.env}-eks-cluster"
  cluster_version = "1.30"

  vpc_id                   = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids               = data.terraform_remote_state.vpc.outputs.private_subnets
  control_plane_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnets

  cluster_endpoint_public_access  = false
  cluster_endpoint_private_access = true

  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  eks_managed_node_groups = {
    frontend = {
      instance_types = ["t4g.micro"]
      desired_size   = 1
      min_size       = 1
      max_size       = 4
      subnet_ids     = data.terraform_remote_state.vpc.outputs.public_subnets
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
      subnet_ids     = data.terraform_remote_state.vpc.outputs.private_subnets
      ami_type       = "AL2_ARM_64"
      labels = {
        role = "backend"
      }
    }
  }

  # Add the current user as cluster admin
  enable_cluster_creator_admin_permissions = true
  create_cloudwatch_log_group              = false
  cluster_enabled_log_types                = []

  tags = merge(local.tags, {
    "Name" = "${local.org}-${local.env}-eks-cluster"
  })
}
