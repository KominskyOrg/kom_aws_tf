output "acm_cert_arn" {
  description = "The CA certificate for the EKS cluster"
  value       = aws_acm_certificate_validation.wildcard_cert_validation.certificate_arn
  sensitive   = true
}
