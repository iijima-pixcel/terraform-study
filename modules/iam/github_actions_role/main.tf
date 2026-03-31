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
    Name    = "${var.name_prefix}-github-oidc"
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
    Name    = var.role_name
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    sid    = "Ec2AssumeRole"
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2" {
  name               = "${var.name_prefix}-EC2-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name    = "${var.name_prefix}-EC2-Role"
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-ec2-instance-profile"
  role = aws_iam_role.ec2.name
}

data "aws_iam_policy_document" "ec2_ssm_policy" {
  statement {
    sid    = "ReadSsmParameter"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]

    resources = [local.ssm_db_password_arn]
  }

  statement {
    sid    = "DecryptViaSsm"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [
      data.aws_kms_key.ssm.arn
    ]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${data.aws_region.current.id}.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "ec2_ssm_policy" {
  name   = "${var.name_prefix}-ec2-ssm-policy"
  policy = data.aws_iam_policy_document.ec2_ssm_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_ssm_policy.arn
}

data "aws_iam_policy_document" "github_actions_terraform_policy" {
  statement {
    sid    = "Ec2Describe"
    effect = "Allow"

    actions = [
      "ec2:Describe*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ElbDescribe"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:Describe*"
    ]

    resources = ["*"]
  }

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
    sid    = "CloudWatchDescribe"
    effect = "Allow"

    actions = [
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "LogsDescribe"
    effect = "Allow"

    actions = [
      "logs:Describe*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "SnsList"
    effect = "Allow"

    actions = [
      "sns:ListTopics",
      "sns:ListSubscriptionsByTopic",
      "sns:GetTopicAttributes"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "IamReadForPassRoleTarget"
    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "SsmReadPassword"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]

    resources = [local.ssm_db_password_arn]
  }

  statement {
    sid    = "KmsDecryptViaSsm"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [data.aws_kms_key.ssm.arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${data.aws_region.current.id}.amazonaws.com"]
    }
  }

  statement {
    sid    = "Ec2Create"
    effect = "Allow"

    actions = [
      "ec2:CreateVpc",
      "ec2:CreateSubnet",
      "ec2:CreateInternetGateway",
      "ec2:CreateRouteTable",
      "ec2:CreateNatGateway",
      "ec2:AttachInternetGateway",
      "ec2:AssociateRouteTable",
      "ec2:AllocateAddress",
      "ec2:CreateSecurityGroup",
      "ec2:RunInstances",
      "ec2:CreateNetworkInterface",
      "ec2:CreateRoute",
      "ec2:CreateTags"
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
    sid    = "CloudWatchAlarmsAwsStudy"
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:DisableAlarmActions"
    ]

    resources = [
      "arn:aws:cloudwatch:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:alarm:${var.name_prefix}-*"
    ]
  }

  statement {
    sid    = "SnsTopicAwsStudy"
    effect = "Allow"

    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:SetTopicAttributes",
      "sns:GetTopicAttributes"
    ]

    resources = [
      "arn:aws:sns:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${var.name_prefix}-*"
    ]
  }

  statement {
    sid    = "PassOnlyEc2Role"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [aws_iam_role.ec2.arn]
  }

  statement {
    sid    = "Ec2ModifyDeleteAwsStudy"
    effect = "Allow"

    actions = [
      "ec2:DeleteVpc",
      "ec2:DeleteSubnet",
      "ec2:DetachInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteRouteTable",
      "ec2:DeleteNatGateway",
      "ec2:ReleaseAddress",
      "ec2:DeleteRoute",
      "ec2:DisassociateRouteTable",
      "ec2:DeleteNetworkInterface",
      "ec2:ModifyVpcAttribute",
      "ec2:ModifySubnetAttribute",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:DeleteSecurityGroup",
      "ec2:TerminateInstances"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Project"
      values   = [var.project]
    }
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

resource "aws_iam_policy" "github_actions_terraform" {
  name        = "${var.role_name}-policy"
  description = "Policy for GitHub Actions Terraform execution role"
  policy      = data.aws_iam_policy_document.github_actions_terraform_policy.json

  tags = {
    Name    = "${var.role_name}-policy"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_actions_terraform.arn
}
