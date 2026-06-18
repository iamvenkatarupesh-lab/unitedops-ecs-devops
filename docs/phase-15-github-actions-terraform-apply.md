# Phase 15: GitHub Actions Terraform Apply

## What We Are Doing

We are adding a manually triggered GitHub Actions workflow that can run `terraform apply`.

## Why We Are Doing It

Terraform plan shows what would change. Terraform apply changes real AWS infrastructure.

Because apply is higher risk, this workflow is not triggered by push. It only runs when manually started from GitHub Actions, and it requires typing a confirmation value.

## Safety Controls

- The workflow uses `workflow_dispatch` only.
- It requires the confirmation input `apply`.
- It runs `terraform plan -out=tfplan`.
- It applies the saved plan with `terraform apply tfplan`.
- It uses the same S3 backend and DynamoDB locking as local Terraform.

## Interview Explanation

You can say:

> I added a protected manual Terraform apply workflow in GitHub Actions. It uses S3 remote state with DynamoDB locking, requires explicit manual confirmation, generates a saved Terraform plan, and applies that exact plan to reduce accidental infrastructure changes.
