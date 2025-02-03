terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "us-east-1"
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.org}-${var.infra_env}-tf-state"
    key    = "kom_aws_tf/vpc/${var.infra_env}/terraform_state.tfstate"
    region = var.region
  }
}

data "terraform_remote_state" "main_infra" {
  backend = "s3"
  config = {
    bucket = "tf-statelock"
    key    = "kom_aws_tf/terraform_state.tfstate"
    region = var.region
  }
}

resource "kubernetes_namespace" "environment" {
  metadata {
    name = var.infra_env
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_name
}

