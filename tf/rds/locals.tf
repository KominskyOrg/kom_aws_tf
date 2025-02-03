locals {
  org       = var.org
  infra_env = var.infra_env

  tags = {
    Environment = local.infra_env
    ManagedBy   = "Terraform"
    Org         = local.org
    Region      = var.region
  }
}
