# Phase 14: GitHub Actions Terraform Plan

## What We Are Doing

We are adding a GitHub Actions workflow that runs Terraform plan against the shared S3 remote state backend.

## Why We Are Doing It

Now that Terraform state is stored in S3 and protected by DynamoDB locking, CI can safely read the same infrastructure state as your local machine.

This workflow still does not run `terraform apply`. It only checks what Terraform would change.

## Workflow

`terraform-plan.yml` does the following:

- configures AWS credentials
- creates `backend.hcl` from GitHub secrets
- creates `terraform.auto.tfvars` from GitHub secrets
- runs `terraform fmt -check`
- runs `terraform init`
- runs `terraform validate`
- runs `terraform plan`

## Required GitHub Secrets

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_ACCOUNT_ID`
- `AWS_REGION`

## Interview Explanation

You can say:

> After migrating Terraform state to S3 with DynamoDB locking, I added a GitHub Actions workflow that runs Terraform plan against remote state. This allows infrastructure changes to be reviewed in CI before any manual apply.
