terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }

  backend "s3" {
    bucket         = "tf-statelock"
    key            = "kom_aws_tf/rds/terraform_state.tfstate"
    region         = "us-east-1"
    dynamodb_table = "tf-state-table"
    encrypt        = true
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "tf-statelock"
    key    = "kom_aws_tf/vpc/terraform_state.tfstate"
    region = "us-east-1"
  }
}
