# Phase 6: Terraform ECS Foundation

## What We Are Doing

We are using Terraform to create the first AWS environment for UnitedOps:

- VPC
- public subnets
- internet gateway
- route table
- Application Load Balancer
- ECS cluster
- ECS task execution role
- CloudWatch log group
- ECS task definition and service for `flight-service`

## Why We Are Doing It

ECS needs AWS infrastructure around it. A container image in ECR is only a package. To run that package, AWS needs networking, permissions, compute configuration, logs, and routing.

Terraform lets us define that infrastructure as code instead of clicking through the AWS Console.

## Beginner-Friendly Design Choice

This first version uses public subnets and assigns a public IP to the ECS task. That avoids NAT Gateway cost while we learn ECS. A more production-like version would put ECS tasks in private subnets and use NAT Gateway or VPC endpoints for outbound AWS access.

## Interview Explanation

You can say:

> I provisioned the ECS foundation with Terraform, including VPC networking, an Application Load Balancer, ECS Fargate service, IAM task execution role, and CloudWatch logging. I first deployed one service to reduce troubleshooting scope, then planned to add additional services and path-based routing.

## Apply Commands

From the project root:

```bash
cd infra/terraform/dev
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and replace `YOUR_ACCOUNT_ID` with your AWS account ID.

Then run:

```bash
terraform init
terraform plan
terraform apply
```

After apply:

```bash
terraform output flight_service_url
```

Open the URL or test:

```bash
curl http://ALB_DNS_NAME/health
```

## Teardown

When you are done practicing:

```bash
terraform destroy
```
