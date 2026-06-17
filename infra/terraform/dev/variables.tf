variable "aws_region" {
  description = "AWS region where the dev environment will be deployed."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name prefix used for AWS resources."
  type        = string
  default     = "unitedops"
}

variable "environment" {
  description = "Deployment environment name."
  type        = string
  default     = "dev"
}

variable "flight_service_image" {
  description = "Full ECR image URI for the flight service."
  type        = string
}

variable "booking_service_image" {
  description = "Full ECR image URI for the booking service."
  type        = string
}

variable "checkin_service_image" {
  description = "Full ECR image URI for the check-in service."
  type        = string
}

variable "notification_service_image" {
  description = "Full ECR image URI for the notification service."
  type        = string
}

variable "backend_service_desired_count" {
  description = "Number of tasks to run for each backend service."
  type        = number
  default     = 1
}

variable "backend_service_min_capacity" {
  description = "Minimum ECS task count for each backend service."
  type        = number
  default     = 1
}

variable "backend_service_max_capacity" {
  description = "Maximum ECS task count for each backend service."
  type        = number
  default     = 2
}

variable "backend_service_cpu_target" {
  description = "Average CPU utilization target percentage for ECS autoscaling."
  type        = number
  default     = 60
}

variable "db_name" {
  description = "PostgreSQL database name."
  type        = string
  default     = "unitedops"
}

variable "db_username" {
  description = "PostgreSQL master username."
  type        = string
  default     = "unitedops"
}
