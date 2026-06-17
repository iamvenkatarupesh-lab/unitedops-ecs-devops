resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  for_each = local.backend_services

  alarm_name          = "${local.name_prefix}-${each.key}-ecs-cpu-high"
  alarm_description   = "ECS service ${each.value.name} average CPU is above 80 percent."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.backend[each.key].name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  for_each = local.backend_services

  alarm_name          = "${local.name_prefix}-${each.key}-ecs-memory-high"
  alarm_description   = "ECS service ${each.value.name} average memory is above 80 percent."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    ClusterName = aws_ecs_cluster.main.name
    ServiceName = aws_ecs_service.backend[each.key].name
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_targets" {
  for_each = local.backend_services

  alarm_name          = "${local.name_prefix}-${each.key}-alb-unhealthy-targets"
  alarm_description   = "ALB target group for ${each.value.name} has unhealthy targets."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    LoadBalancer = aws_lb.app.arn_suffix
    TargetGroup  = aws_lb_target_group.backend[each.key].arn_suffix
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_cpu_high" {
  alarm_name          = "${local.name_prefix}-rds-cpu-high"
  alarm_description   = "RDS PostgreSQL average CPU is above 80 percent."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 80
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "rds_storage_low" {
  alarm_name          = "${local.name_prefix}-rds-free-storage-low"
  alarm_description   = "RDS PostgreSQL free storage is below 2 GiB."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 2147483648
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.postgres.identifier
  }

  tags = local.common_tags
}
