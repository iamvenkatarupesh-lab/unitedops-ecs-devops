# Phase 12: GitHub Actions CI/CD

## What We Are Doing

We are adding GitHub Actions workflows for:

- building Docker images
- pushing images to Amazon ECR
- forcing ECS services to redeploy with the new images
- validating Terraform formatting and syntax

## Why We Are Doing It

Manual deployment is useful while learning, but CI/CD is what makes the project feel like a real DevOps workflow.

After this phase, pushing application code to `main` can automatically build and publish container images, then tell ECS to start a new deployment.

## Workflows

### `deploy-services.yml`

Builds all service images for `linux/amd64`, pushes them to ECR, and forces ECS services to redeploy.

The frontend image is pushed to ECR but not deployed to ECS yet because the current Terraform stack only deploys backend ECS services.

### `terraform-validate.yml`

Runs Terraform format and validate checks. It does not apply Terraform.

### `terraform-plan.yml`

Runs Terraform plan against the shared S3 remote state backend. It does not apply Terraform.

## Why Terraform Apply Is Not Automated Yet

The project now uses remote Terraform state, so GitHub Actions can safely run `terraform plan`.

`terraform apply` is still kept manual for now because this is a learning project and manual approval is safer while infrastructure changes are still being reviewed step by step.

## Required GitHub Secrets

Add these repository secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID`
- `AWS_REGION`

Use `us-east-1` for `AWS_REGION`.

## Interview Explanation

You can say:

> I implemented GitHub Actions workflows that build Docker images for `linux/amd64`, push them to Amazon ECR, force ECS services to redeploy, and run Terraform plan against S3 remote state with DynamoDB locking.
