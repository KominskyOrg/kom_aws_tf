locals {
  vpc_cidr = "192.168.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]
  org      = "kom"
  env      = var.env

  subnet_bits = 8

  public_subnets   = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, local.subnet_bits, i)]
  private_subnets  = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, local.subnet_bits, i + length(local.azs))]
  database_subnets = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, local.subnet_bits, i + 2 * length(local.azs))]

  tags = {
    Environment = local.env
    ManagedBy   = "Terraform"
  }
}
