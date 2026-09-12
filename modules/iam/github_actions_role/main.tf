data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_kms_key" "ssm" {
  key_id = var.ssm_kms_key_id
}

locals {
  github_oidc_url     = "token.actions.githubusercontent.com"
  ssm_db_password_arn = "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:parameter${var.rds_master_password_ssm_name}"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://${local.github_oidc_url}"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = var.github_oidc_thumbprints

  tags = {
    Name = "${var.name_prefix}-github-oidc"
  }
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid    = "GitHubActionsOIDC"
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
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
        "repo:${var.github_organization}/${var.github_repository}:ref:refs/heads/${var.github_branch}",
        "repo:${var.github_organization}/${var.github_repository}:pull_request"
      ]
    }
  }
}

resource "aws_iam_role" "github_actions_terraform" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Name = var.role_name
  }
}
