data "aws_iam_policy_document" "github_actions_network_compute_policy" {

  statement {
    sid    = "Ec2Describe"
    effect = "Allow"

    actions = [
      "ec2:Describe*"
    ]

    resources = ["*"]
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
    sid    = "CreateNatGatewayServiceLinkedRole"
    effect = "Allow"

    actions = [
      "iam:CreateServiceLinkedRole"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/ec2-nat-gateway.amazonaws.com/AWSServiceRoleForNATGateway*"
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["ec2-nat-gateway.amazonaws.com"]
    }
  }

  statement {
    sid    = "PassOnlyEc2Role"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [var.ec2_role_arn]
  }

  statement {
    sid    = "IamReadForPassRoleTarget"
    effect = "Allow"

    actions = [
      "iam:GetRole",
      "iam:GetInstanceProfile",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies"
    ]

    resources = ["*"]
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
}

resource "aws_iam_policy" "github_actions_network_compute" {
  name   = "${var.name_prefix}-GitHubActions-Network-Compute"
  policy = data.aws_iam_policy_document.github_actions_network_compute_policy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_network_compute" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_actions_network_compute.arn
}
