locals {
  org       = "kom"
  infra_env = var.infra_env
  tags = {
    Environment = local.infra_env
    ManagedBy   = "Terraform"
  }
}
