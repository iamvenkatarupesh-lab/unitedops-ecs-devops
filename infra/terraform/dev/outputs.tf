output "alb_dns_name" {
  description = "Public DNS name for the application load balancer."
  value       = aws_lb.app.dns_name
}

output "flight_service_url" {
  description = "URL for the flight service through the load balancer."
  value       = "http://${aws_lb.app.dns_name}"
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "flight_service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.backend["flight"].name
}

output "backend_service_names" {
  description = "Names of the backend ECS services."
  value = {
    for key, service in aws_ecs_service.backend : key => service.name
  }
}

output "database_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = aws_db_instance.postgres.endpoint
}

output "database_secret_name" {
  description = "Secrets Manager secret name containing DATABASE_URL."
  value       = aws_secretsmanager_secret.database_url.name
}
