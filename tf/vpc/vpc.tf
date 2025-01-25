module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "${local.org}-${local.env}-vpc"
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  database_subnets = local.database_subnets

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }

  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_support   = true
  enable_dns_hostnames = true

  create_database_subnet_group = true

  tags = local.tags

  map_public_ip_on_launch = true
}
