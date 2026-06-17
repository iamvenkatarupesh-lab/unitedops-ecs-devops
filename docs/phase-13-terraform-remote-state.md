# Phase 13: Terraform Remote State

## What We Are Doing

We are moving Terraform state from your local machine to an S3 bucket and using DynamoDB for state locking.

## Why We Are Doing It

Terraform state tracks which AWS resources belong to your infrastructure code. If GitHub Actions runs Terraform without the same state file, it may think existing resources do not exist and try to recreate them.

Remote state solves that by giving your laptop and CI/CD the same state source.

State locking prevents two Terraform runs from changing infrastructure at the same time.

## Resources

- S3 bucket: stores `terraform.tfstate`
- DynamoDB table: stores the lock record

## Backend Files

The repo contains:

- `backend.tf`: declares that this environment uses an S3 backend
- `backend.hcl.example`: template for backend configuration

The real `backend.hcl` file is ignored by Git because it contains account-specific configuration.

## Interview Explanation

You can say:

> I migrated Terraform from local state to an S3 remote backend with DynamoDB locking so infrastructure changes can be safely run from multiple environments, including GitHub Actions, without state drift or concurrent apply conflicts.
