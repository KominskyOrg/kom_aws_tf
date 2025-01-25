locals {
  org = "kom"
  env = var.env

  tags = {
    Environment = local.env
    ManagedBy   = "Terraform"
  }
}
