# Phase 7: Multi-Service ECS Routing

## What We Are Doing

We are adding the remaining backend services to ECS Fargate:

- `booking-service`
- `checkin-service`
- `notification-service`

They use the same ECS cluster, VPC, public subnets, IAM execution role, and Application Load Balancer that were created for `flight-service`.

## Why We Are Doing It

A real DevOps project usually has more than one service. This phase teaches how one load balancer can route traffic to multiple ECS services using listener rules and target groups.

## Routing

The Application Load Balancer will route:

- `/flights` and unmatched default traffic to `flight-service`
- `/bookings` to `booking-service`
- `/checkins` to `checkin-service`
- `/notifications` to `notification-service`

Each ECS service has its own:

- task definition
- ECS service
- target group
- CloudWatch log group

## Terraform Pattern

The backend services are defined with a Terraform map and `for_each`. This avoids copy-pasting nearly identical Terraform blocks for every service.

## Refactor Safety

The Terraform config includes `moved` blocks so Terraform understands that the original `flight-service` resources were renamed in code, not removed. This prevents unnecessary destroy/recreate behavior.

## Interview Explanation

You can say:

> I extended the ECS deployment from one service to multiple backend services by using Terraform `for_each`, separate target groups, CloudWatch log groups, task definitions, ECS services, and ALB listener rules for path-based routing.
