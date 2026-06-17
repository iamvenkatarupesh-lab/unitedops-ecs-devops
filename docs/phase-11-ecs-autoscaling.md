# Phase 11: ECS Autoscaling

## What We Are Doing

We are adding Application Auto Scaling for each ECS backend service.

Each service can scale between:

- minimum tasks: `1`
- maximum tasks: `2`

The scaling policy watches average ECS CPU utilization and tries to keep it near `60%`.

## Why We Are Doing It

Autoscaling lets a service respond to changing load without manual intervention. If CPU usage rises, ECS can add another task. When CPU drops, ECS can scale back down.

For this learning project, the maximum is intentionally low to control cost.

## Resources Added

- `aws_appautoscaling_target`
- `aws_appautoscaling_policy`

## Interview Explanation

You can say:

> I configured ECS service autoscaling with Terraform using Application Auto Scaling target tracking policies. Each service scales desired task count between 1 and 2 based on average CPU utilization, with cooldown periods to avoid rapid scaling changes.
