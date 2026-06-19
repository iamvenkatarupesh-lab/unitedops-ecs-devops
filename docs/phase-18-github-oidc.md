# Phase 18: GitHub Actions OIDC

## Goal

Replace stored AWS access keys in GitHub with short-lived credentials issued through OpenID Connect.

## Authentication Flow

1. A permitted GitHub Actions job requests a signed OIDC token.
2. GitHub places repository, branch, and audience claims in the token.
3. AWS validates the token through the GitHub IAM OIDC provider.
4. The IAM role trust policy checks `aud` and `sub` claims.
5. AWS STS returns temporary credentials to the workflow.
6. The role's identity policy controls which AWS actions the job may perform.

No AWS secret access key is stored in GitHub.

## Trust Versus Permissions

The role has two different policy responsibilities:

- **Trust policy:** defines which external identity may assume the role. UnitedOps allows this repository's `main` branch and pull-request context.
- **Identity policy:** defines what the temporary role session may do after assumption. UnitedOps includes remote-state access, ECR deployment actions, ECS operations, project IAM resources, and services managed by Terraform.

Both are required. A narrow permissions policy does not prevent another repository from assuming a role if its trust policy is broad.

## Workflow Changes

AWS-enabled workflows declare:

```yaml
permissions:
  id-token: write
  contents: read
```

The AWS credential action exchanges the token for a temporary role session:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ env.AWS_ROLE_ARN }}
    role-session-name: unitedops-${{ github.run_id }}
    aws-region: ${{ env.AWS_REGION }}
```

`id-token: write` permits requesting an OIDC token; it does not grant write access to AWS or the repository.

## Safe Migration Order

1. Create the OIDC provider, IAM role, and policy using the existing local AWS identity.
2. Validate that the role exists and inspect its trust policy.
3. Push the OIDC workflow changes.
4. Run an AWS-enabled workflow and verify role assumption succeeds.
5. Delete `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` from GitHub only after successful validation.

This order preserves a recovery path if the initial trust or permissions policy is incorrect.

## Validation

```bash
terraform output -raw github_actions_role_arn

aws iam get-role \
  --role-name unitedops-dev-github-actions \
  --query 'Role.AssumeRolePolicyDocument'
```

In GitHub Actions, the `Configure AWS credentials` step should succeed without either access-key secret. AWS CloudTrail records the unique workflow role-session name for audit investigation.
