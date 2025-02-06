terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }

  backend "s3" {}
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "${var.org}-${var.infra_env}-tf-state"
    key    = "kom_aws_tf/vpc/terraform_state.tfstate"
    region = var.region
  }
}
