data "aws_iam_policy_document" "github_actions_app_policy" {

  # =========================
  # ELB
  # =========================

  statement {
    sid    = "ElbDescribe"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:Describe*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ElbCreate"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateTargetGroup",
      "elasticloadbalancing:CreateListener",
      "elasticloadbalancing:AddTags",
      "elasticloadbalancing:RegisterTargets"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ElbOperateAwsStudy"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteTargetGroup",
      "elasticloadbalancing:RegisterTargets",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:RemoveTags",
      "elasticloadbalancing:ModifyTargetGroup",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:ModifyTargetGroupAttributes"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:ResourceTag/Project"
      values   = [var.project]
    }
  }

  statement {
    sid    = "ElbOperateListener"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:DeleteListener",
      "elasticloadbalancing:ModifyListener"
    ]

    resources = ["*"]
  }

  # =========================
  # RDS
  # =========================

  statement {
    sid    = "RdsDescribe"
    effect = "Allow"

    actions = [
      "rds:Describe*",
      "rds:ListTagsForResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "RdsCreate"
    effect = "Allow"

    actions = [
      "rds:CreateDBInstance",
      "rds:CreateDBSubnetGroup",
      "rds:AddTagsToResource"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "RdsOperateAwsStudy"
    effect = "Allow"

    actions = [
      "rds:DeleteDBInstance",
      "rds:DeleteDBSubnetGroup",
      "rds:ModifyDBInstance",
      "rds:CreateDBSnapshot",
      "rds:DeleteDBSnapshot"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "rds:db-tag/Project"
      values   = [var.project]
    }
  }
}

resource "aws_iam_policy" "github_actions_app" {
  name   = "${var.name_prefix}-GitHubActions-App"
  policy = data.aws_iam_policy_document.github_actions_app_policy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_app" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_actions_app.arn
}
