data "aws_iam_policy_document" "github_actions_vpc_endpoints_policy" {
  statement {
    sid    = "CreateTaggedVpcEndpoints"
    effect = "Allow"

    actions = [
      "ec2:CreateVpcEndpoint"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ModifyDeleteTaggedVpcEndpoints"
    effect = "Allow"

    actions = [
      "ec2:ModifyVpcEndpoint",
      "ec2:DeleteVpcEndpoints"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Project"
      values   = [var.project]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/Environment"
      values   = [var.environment]
    }
  }

  statement {
    sid    = "DescribeVpcEndpoints"
    effect = "Allow"

    actions = [
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeRouteTables"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageVpcEndpointTags"
    effect = "Allow"

    actions = [
      "ec2:CreateTags",
      "ec2:DeleteTags"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_vpc_endpoints" {
  name        = "${var.name_prefix}-GitHubActions-VpcEndpoints-Policy"
  description = "Policy for GitHub Actions to manage SSM VPC endpoints"
  policy      = data.aws_iam_policy_document.github_actions_vpc_endpoints_policy.json

  tags = {
    Name = "${var.name_prefix}-GitHubActions-VpcEndpoints-Policy"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_vpc_endpoints" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_actions_vpc_endpoints.arn
}
