output "application_load_balancer_dns" {
  description = "The public URL to test the web application"
  value       = module.compute.alb_dns_name
}

output "database_endpoint" {
  description = "The connection endpoint for the RDS database"
  value       = module.database.rds_endpoint
}