variable "local_ip" {
  description = "Local IP address for security group ingress"
  type        = string
}

variable "env" {
  description = "Environment to deploy to"
  type        = string
  default     = "staging"
} 