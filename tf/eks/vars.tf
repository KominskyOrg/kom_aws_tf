variable "org" {
  description = "Organization name"
  type        = string
}

variable "env" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "local_ip" {
  description = "Local IP address for security group ingress"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the resources will be created"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnet IDs"
  type        = list(string)
}