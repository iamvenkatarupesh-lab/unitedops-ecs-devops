# UnitedOps Resume and Interview Guide

## Resume Project Entry

**UnitedOps ECS DevOps Platform** | AWS, ECS Fargate, Terraform, Docker, GitHub Actions, RDS, CloudWatch

- Built and deployed four containerized Node.js/TypeScript microservices on Amazon ECS Fargate, using an Application Load Balancer with path-based routing and health checks.
- Provisioned VPC networking, ECS, ALB, IAM, RDS PostgreSQL, Secrets Manager, monitoring, and autoscaling with Terraform; stored encrypted remote state in S3 with DynamoDB locking.
- Automated Docker builds, ECR pushes, rolling ECS deployments, Terraform validation, remote-state plans, and confirmation-gated applies with GitHub Actions.
- Implemented CloudWatch logging and 14 infrastructure alarms across ECS, ALB, and RDS, plus target-tracking scaling from one to two tasks per service at 60% CPU.

Only use metrics you can explain and reproduce. The last bullet is accurate for the implemented development environment, but it should not be presented as production experience.

## 60-Second Project Explanation

“I built UnitedOps to learn the complete delivery and operations lifecycle on ECS after previously using EKS. It contains four simple airline APIs packaged as Docker images. GitHub Actions builds Linux AMD64 images, pushes them to ECR, and triggers rolling deployments to ECS Fargate. An Application Load Balancer uses path-based rules to route traffic to separate ECS services and target groups. The services use RDS PostgreSQL, with the database URL stored in Secrets Manager and injected at runtime. I provisioned the environment with Terraform, moved its state to encrypted S3 with DynamoDB locking, and added separate validate, plan, and manually approved apply workflows. For operations, I added CloudWatch logs and alarms plus CPU target-tracking autoscaling. I validated the application endpoints, running task counts, database persistence, logs, alarms, and scaling policies.”

## How to Explain the Architecture

Start at the request and move inward:

1. **ALB:** one public endpoint accepts HTTP requests and selects a target group from the path.
2. **Target group:** performs health checks and contains the private IP addresses of healthy Fargate tasks.
3. **ECS service:** keeps the desired number of tasks running and performs rolling replacements.
4. **Task definition:** defines the image, CPU, memory, port, logging, IAM execution role, and secret injection.
5. **Fargate:** supplies managed compute for each task, so there are no EC2 worker nodes to patch.
6. **RDS and Secrets Manager:** provide persistent data and runtime database credentials.
7. **CloudWatch and autoscaling:** capture output, observe metrics, alert on risk, and change desired capacity.

## ECS Versus EKS

| Topic | ECS Fargate in UnitedOps | EKS in PayPulse |
| --- | --- | --- |
| Control plane | AWS-native ECS service | Managed Kubernetes control plane |
| Deployment object | Task definition and ECS service | Deployment, Service, ConfigMap, Secret, Helm release |
| Compute | Fargate tasks | Kubernetes pods on nodes or Fargate |
| Traffic | ALB listener rules and target groups | Ingress/controller and Kubernetes Services |
| Scaling | Application Auto Scaling on desired count | Horizontal Pod Autoscaler and cluster capacity |
| Operational overhead | Lower for an AWS-only application | More flexibility, portability, and ecosystem complexity |

**Interview answer:** ECS was a good fit because the goal was to run containers on AWS with less orchestration overhead. EKS is a stronger choice when Kubernetes APIs, portability, advanced scheduling, or its ecosystem are requirements. The decision should come from workload and organizational needs, not which service is “better.”

## Decisions and Tradeoffs

### Why Fargate?

It removes EC2 node provisioning and patching, allowing the project to focus on container definitions, networking, IAM, delivery, and service reliability. The tradeoff is less host-level control and potentially higher steady-state cost than well-utilized EC2 capacity.

### Why one ALB?

Path-based routing exposes several APIs through one endpoint and avoids paying for an ALB per service. It also creates shared infrastructure and a possible shared failure domain.

### Why remote Terraform state?

Local state is unsuitable for team automation. S3 makes state available to CI and collaborators; encryption protects it at rest; locking prevents two applies from changing it simultaneously.

### Why a manual apply?

Infrastructure changes have a larger blast radius than a normal application build. The workflow validates first, creates a saved plan, requires explicit confirmation, and applies exactly that plan.

### Why is `latest` a limitation?

An updated `latest` tag does not provide immutable release identity or reliable rollback. A production pipeline should tag each image with the Git commit SHA, update the task definition to that exact tag or digest, and retain previous task definition revisions.

### Why are long-lived GitHub AWS keys a limitation?

They require storage and rotation. A production improvement is GitHub Actions OIDC: GitHub receives a short-lived token and assumes a narrowly scoped IAM role without storing an AWS secret access key.

## Troubleshooting Stories

### Docker daemon unavailable

`docker compose up --build` initially could not connect to the Docker socket, so no containers or ports existed and every `curl` failed. The diagnostic sequence was to confirm Docker Desktop was running, rerun Compose, inspect `docker compose ps`, and test each health endpoint. This separated an environment problem from an application problem.

### ALB placeholder used literally

A health check failed because `PASTE_ALB_DNS_NAME` was used as a hostname. Reading `terraform output` and using `terraform output -raw flight_service_url` produced the real endpoint. This showed why automation-friendly outputs are safer than manual copy-and-replace steps.

### GitHub Terraform apply returned code 3

The workflow generated a `.tfvars` file before running `terraform fmt -check`, so formatting validation included a generated file and failed. Moving the format check before file generation made validation deterministic. The lesson was that CI step order and generated artifacts affect the workspace being validated.

## Questions You Should Be Ready For

**How does ECS recover from failure?**  
The ECS service compares desired count with running healthy tasks. If a task exits or fails load balancer health checks, ECS starts a replacement; the ALB sends traffic only to healthy registered targets.

**What is the difference between an ECS task and service?**  
A task is one running instance of a task definition. A service manages long-running tasks, maintains desired count, integrates with load balancing, and handles deployments.

**Why does an ECS task need IAM roles?**  
The execution role lets the ECS agent pull images, publish logs, and retrieve configured secrets. A separate task role should grant application code only the AWS API permissions it needs.

**How is a deployment performed?**  
GitHub Actions builds and pushes an image, then requests a forced ECS deployment. ECS starts replacement tasks, waits for health checks, shifts traffic, and stops old tasks according to deployment settings.

**How would you improve zero-downtime releases?**  
Use immutable image tags, explicit task definition revisions, deployment circuit breaker rollback, tuned health-check grace periods, and blue/green deployment through CodeDeploy for higher-risk services.

**What happens when CPU exceeds the target?**  
Target tracking asks Application Auto Scaling to increase the ECS service desired count, up to two in this development environment. It scales in after utilization falls and cooldown conditions are met.

**What is still not production-ready?**  
The environment uses HTTP, a small single development database, long-lived CI credentials, mutable image tags, and a low scaling ceiling. Production would add HTTPS with ACM, Route 53, multi-AZ RDS, backups and recovery tests, OIDC, immutable releases, least-privilege review, WAF, stronger network isolation, and load testing.

## Honest Interview Language

Say: “I designed, implemented, and validated this as a hands-on personal project.”

Do not say: “I operated this in production” or imply it served real United Airlines traffic. The airline domain makes the project relevant; UnitedOps is not affiliated with United Airlines.
