output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = module.eks.eks_cluster_endpoint
  sensitive   = true
}

output "eks_cluster_ca_cert" {
  description = "Certificate authority data for the EKS cluster"
  value       = module.eks.eks_cluster_ca_cert
  sensitive   = true
}

output "db_host" {
  description = "The host of the RDS database"
  value       = module.rds.db_host
  sensitive   = true
}

output "db_port" {
  description = "The port of the RDS database"
  value       = module.rds.db_port
}
