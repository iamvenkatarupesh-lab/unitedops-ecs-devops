# Phase 17: Frontend on ECS Fargate

## Goal

Deploy the Next.js frontend as the fifth ECS Fargate service and serve it from the existing Application Load Balancer.

## Why This Design

The ALB already provides the system's public entry point. Its default action now forwards unmatched paths such as `/` to the frontend target group. Explicit listener rules have higher priority and continue forwarding API paths to the four backend target groups.

This produces one browser-friendly origin:

```text
http://ALB_DNS/                 -> frontend
http://ALB_DNS/health          -> flight service
http://ALB_DNS/flights         -> flight service
http://ALB_DNS/bookings        -> booking service
http://ALB_DNS/checkins        -> check-in service
http://ALB_DNS/notifications   -> notification service
```

Using relative API paths in the AWS frontend avoids hard-coding an ALB hostname into the image and avoids browser cross-origin configuration. Local Docker Compose supplies build arguments so the same frontend still links to ports `4001` through `4004` during local development.

## Resources Added

- Frontend ECS task definition and service on port `3000`
- Frontend ALB target group with a `/` health check
- ALB security-group ingress from the load balancer to task port `3000`
- Frontend CloudWatch log group
- CPU, memory, and unhealthy-target alarms
- CPU target-tracking autoscaling from one to two tasks
- Terraform outputs for the frontend URL and ECS service name
- GitHub Actions deployment of the frontend ECS service

## Deployment Order

The frontend image must exist in ECR before Terraform creates its ECS task. Build and push it first, then add `frontend_image` to the ignored local `terraform.tfvars`, review the Terraform plan, and apply it.

```hcl
frontend_image = "YOUR_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/unitedops-frontend:latest"
```

## Validation

```bash
terraform output

curl -I "$(terraform output -raw frontend_url)"
curl "$(terraform output -raw frontend_url)/flights"

aws ecs describe-services \
  --cluster "$(terraform output -raw ecs_cluster_name)" \
  --services "$(terraform output -raw frontend_service_name)" \
  --region us-east-1 \
  --query 'services[0].{status:status,desired:desiredCount,running:runningCount,pending:pendingCount}'
```

Successful validation means the root URL returns HTTP `200`, `/flights` still returns JSON, and the frontend ECS service reports `ACTIVE`, desired `1`, running `1`, pending `0`.
