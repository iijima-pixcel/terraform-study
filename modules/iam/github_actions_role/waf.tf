data "aws_iam_policy_document" "github_actions_waf_policy" {
  statement {
    sid    = "CreateWafWebAcl"
    effect = "Allow"

    actions = [
      "wafv2:CreateWebACL",
      "wafv2:ListWebACLs"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "ManageNamedWafWebAcl"
    effect = "Allow"

    actions = [
      "wafv2:GetWebACL",
      "wafv2:UpdateWebACL",
      "wafv2:DeleteWebACL",
      "wafv2:TagResource",
      "wafv2:UntagResource",
      "wafv2:ListTagsForResource",
      "wafv2:AssociateWebACL",
      "wafv2:DisassociateWebACL"
    ]

    resources = [
      "arn:aws:wafv2:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:regional/webacl/${var.name_prefix}-waf/*"
    ]
  }

  statement {
    sid    = "GetWafAssociation"
    effect = "Allow"

    actions = [
      "wafv2:GetWebACLForResource"
    ]

    resources = [
      "arn:aws:wafv2:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:regional/webacl/*/*"
    ]
  }

  statement {
    sid    = "SetWebAclToAlb"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:SetWebACL"
    ]

    resources = [
      "arn:aws:elasticloadbalancing:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:loadbalancer/app/${var.name_prefix}ALB/*"
    ]
  }
}

resource "aws_iam_policy" "github_actions_waf" {
  name   = "${var.name_prefix}-GitHubActions-WAF-Policy"
  policy = data.aws_iam_policy_document.github_actions_waf_policy.json

  tags = {
    Name = "${var.name_prefix}-GitHubActions-WAF-Policy"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_waf" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_actions_waf.arn
}
