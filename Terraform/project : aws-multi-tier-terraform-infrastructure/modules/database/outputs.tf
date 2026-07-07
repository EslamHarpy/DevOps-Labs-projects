output "rds_endpoint" {
  value = aws_db_instance.production_db.endpoint
}