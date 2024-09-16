terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket         = "tf-statelock"
    key            = "kom_aws_tf.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-table"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  vpc_cidr = "192.168.0.0/16"
  azs      = ["us-east-1a", "us-east-1b"]
  org     = "kominskyorg"
  env      = "dev"

  subnet_bits = 8

  public_subnets   = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, local.subnet_bits, i)]
  private_subnets  = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, local.subnet_bits, i + length(local.azs))]
  database_subnets = [for i in range(length(local.azs)) : cidrsubnet(local.vpc_cidr, local.subnet_bits, i + 2 * length(local.azs))]

  tags = {
    Environment = local.env
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "${local.org}-${local.env}-vpc"
  cidr = local.vpc_cidr
  azs  = local.azs

  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  database_subnets = local.database_subnets

  enable_nat_gateway   = false
  single_nat_gateway   = false
  enable_dns_support   = true
  enable_dns_hostnames = true

  create_database_subnet_group = true

  tags = local.tags
}
