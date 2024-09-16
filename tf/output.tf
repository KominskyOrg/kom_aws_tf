output "eks_cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.eks_cluster_name
}

output "eks_cluster_endpoint" {
  description = "Endpoint of the EKS cluster"
  value       = module.eks.eks_cluster_endpoint
}

output "eks_cluster_ca_cert" {
  description = "Certificate authority data for the EKS cluster"
  value       = module.eks.eks_cluster_ca_cert
}
