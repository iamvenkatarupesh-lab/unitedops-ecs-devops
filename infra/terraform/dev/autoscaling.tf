resource "aws_appautoscaling_target" "backend" {
  for_each = local.backend_services

  max_capacity       = var.backend_service_max_capacity
  min_capacity       = var.backend_service_min_capacity
  resource_id        = "service/${aws_ecs_cluster.main.name}/${aws_ecs_service.backend[each.key].name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  depends_on = [
    aws_ecs_service.backend
  ]
}

resource "aws_appautoscaling_policy" "backend_cpu" {
  for_each = local.backend_services

  name               = "${local.name_prefix}-${each.key}-cpu-target-tracking"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend[each.key].resource_id
  scalable_dimension = aws_appautoscaling_target.backend[each.key].scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend[each.key].service_namespace

  target_tracking_scaling_policy_configuration {
    target_value       = var.backend_service_cpu_target
    scale_in_cooldown  = 300
    scale_out_cooldown = 60

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}
