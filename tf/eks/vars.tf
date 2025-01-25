variable "env" {
  description = "Environment name (e.g., staging, prod)"
  type        = string
  default     = "staging"
}

variable "local_ip" {
  description = "Local IP address for security group ingress"
  type        = string
}
