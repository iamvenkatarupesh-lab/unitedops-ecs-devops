moved {
  from = aws_cloudwatch_log_group.flight_service
  to   = aws_cloudwatch_log_group.backend["flight"]
}

moved {
  from = aws_lb_target_group.flight_service
  to   = aws_lb_target_group.backend["flight"]
}

moved {
  from = aws_ecs_task_definition.flight_service
  to   = aws_ecs_task_definition.backend["flight"]
}

moved {
  from = aws_ecs_service.flight_service
  to   = aws_ecs_service.backend["flight"]
}
