locals {
  vpc_cidr  = "192.168.0.0/16"
  azs       = ["us-east-1a", "us-east-1b"]
  org       = var.org
  infra_env = var.infra_env

  subnet_bits = 8

  public_subnets   = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, local.subnet_bits, i)]
  private_subnets  = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, local.subnet_bits, i + length(local.azs))]
  database_subnets = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, local.subnet_bits, i + 2 * length(local.azs))]

  tags = {
    Environment = local.infra_env
    ManagedBy   = "Terraform"
    Org         = local.org
    Region      = var.region
  }
}
