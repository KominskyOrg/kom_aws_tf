output "db_secret_name" {
  description = "The name of the secret for the RDS database"
  value       = data.aws_secretsmanager_secret.db_secret.name
}