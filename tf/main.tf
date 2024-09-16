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
  org      = "kominskyorg"
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
  source           = "./vpc"
  public_subnets   = local.public_subnets
  private_subnets  = local.private_subnets
  database_subnets = local.database_subnets
  org              = local.org
  env              = local.env
  azs              = local.azs
  vpc_cidr         = local.vpc_cidr
}

module "eks" {
  source          = "./eks"
  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnets
  private_subnets = module.vpc.private_subnets
  org             = local.org
  env             = local.env
  local_ip        = var.local_ip
}

module "rds" {
  source           = "./rds"
  vpc_id           = module.vpc.vpc_id
  database_subnets = module.vpc.database_subnets
  vpc_cidr_block   = local.vpc_cidr
  env              = local.env
  org              = local.org
  local_ip         = var.local_ip
}
