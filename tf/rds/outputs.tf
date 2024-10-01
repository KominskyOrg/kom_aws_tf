output "db_secret_arn" {
  description = "The arn of the secret for the RDS database"
  value       = module.rds.db_instance_master_user_secret_arn
}

output "db_host" {
  description = "The endpoint of the RDS database"
  value       = module.rds.db_instance_address
}

output "db_port" {
  description = "The port of the RDS database"
  value       = module.rds.db_instance_port
}

output "db_security_group_id" {
  description = "The ID of the security group for the RDS database"
  value       = module.rds_sg.security_group_id
}
