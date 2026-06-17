# UnitedOps ECS DevOps Platform

UnitedOps is a beginner-friendly, resume-ready DevOps project that deploys a small airline operations platform to AWS ECS Fargate.

The project is intentionally simple on the application side so the main learning stays on DevOps concepts: Docker, ECS, Fargate, ECR, ALB, RDS, Secrets Manager, Terraform, GitHub Actions, CloudWatch, autoscaling, and safe teardown.

## Phase 1 Goal

Run a small airline-themed system locally:

- `frontend`: dashboard UI
- `flight-service`: flight search and status API
- `booking-service`: reservation API
- `checkin-service`: passenger check-in API
- `notification-service`: notification event API
- `postgres`: local database for development

## Why This Phase Matters

Before deploying anything to AWS, we need a predictable local baseline. If services cannot run locally, Docker and ECS will only make debugging harder.

In interviews, this helps you explain that you validated the application first, then containerized it, then deployed it through infrastructure as code and CI/CD.

## Local Ports

| Service | Port |
| --- | --- |
| Frontend | `3000` |
| Flight Service | `4001` |
| Booking Service | `4002` |
| Check-In Service | `4003` |
| Notification Service | `4004` |
| PostgreSQL | `5432` |

## Health Checks

Each backend service exposes:

```bash
GET /health
```

Example:

```bash
curl http://localhost:4001/health
```

## Next Phases

1. Run services locally.
2. Dockerize each service.
3. Push images to Amazon ECR.
4. Create AWS infrastructure with Terraform.
5. Deploy services to ECS Fargate behind an ALB.
6. Add RDS, Secrets Manager, CloudWatch, autoscaling, and GitHub Actions CI/CD.
