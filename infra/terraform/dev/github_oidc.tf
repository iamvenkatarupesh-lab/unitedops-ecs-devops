data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = local.common_tags
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:${var.github_repository}:ref:refs/heads/main",
        "repo:${var.github_repository}:pull_request"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "${local.name_prefix}-github-actions"
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = local.common_tags
}

data "aws_iam_policy_document" "github_actions" {
  statement {
    sid = "TerraformRemoteState"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::unitedops-terraform-state-${data.aws_caller_identity.current.account_id}",
      "arn:aws:s3:::unitedops-terraform-state-${data.aws_caller_identity.current.account_id}/*"
    ]
  }

  statement {
    sid = "TerraformStateLock"
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/unitedops-terraform-locks"
    ]
  }

  statement {
    sid = "ContainerRegistryAuthentication"
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    sid = "UnitedOpsContainerRepositories"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/unitedops-*"
    ]
  }

  statement {
    sid = "UnitedOpsInfrastructure"
    actions = [
      "application-autoscaling:*",
      "cloudwatch:*",
      "ec2:*",
      "ecs:*",
      "elasticloadbalancing:*",
      "logs:*",
      "rds:*",
      "secretsmanager:*"
    ]
    resources = ["*"]
  }

  statement {
    sid = "UnitedOpsIAMResources"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateRole",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListPolicyVersions",
      "iam:ListRolePolicies",
      "iam:PassRole",
      "iam:PutRolePolicy",
      "iam:TagPolicy",
      "iam:TagRole",
      "iam:UntagPolicy",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.name_prefix}-*",
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/${local.name_prefix}-*"
    ]
  }

  statement {
    sid = "GitHubOIDCProvider"
    actions = [
      "iam:DeleteOpenIDConnectProvider",
      "iam:GetOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:UntagOpenIDConnectProvider",
      "iam:UpdateOpenIDConnectProviderThumbprint"
    ]
    resources = [
      aws_iam_openid_connect_provider.github_actions.arn
    ]
  }
}

resource "aws_iam_policy" "github_actions" {
  name        = "${local.name_prefix}-github-actions"
  description = "Allows GitHub Actions to deploy and manage the UnitedOps development environment."
  policy      = data.aws_iam_policy_document.github_actions.json

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "github_actions" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions.arn
}
