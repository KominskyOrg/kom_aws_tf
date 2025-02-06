variable "local_ip" {
  description = "Local IP address for security group ingress"
  type        = string
}

variable "infra_env" {
  description = "Environment to deploy to"
  type        = string
}

variable "org" {
  description = "Organization to deploy to"
  type        = string
}

variable "region" {
  description = "Region to deploy to"
  type        = string
}
