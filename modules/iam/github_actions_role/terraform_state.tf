
data "aws_iam_policy_document" "github_actions_core_policy" {
  statement {
    sid    = "TerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.state_bucket_name}"
    ]
  }

  statement {
    sid    = "TerraformStateObject"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${var.state_bucket_name}/*"
    ]
  }

  statement {
    sid    = "TerraformStateLockTable"
    effect = "Allow"

    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem"
    ]

    resources = [
      "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.lock_table_name}"
    ]
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
}

resource "aws_iam_policy" "github_actions_core" {
  name        = "${var.role_name}-policy"
  description = "Policy for GitHub Actions Terraform execution role"
  policy      = data.aws_iam_policy_document.github_actions_core_policy.json

  tags = {
    Name = "${var.role_name}-policy"
  }
}

resource "aws_iam_role_policy_attachment" "github_actions_core" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_actions_core.arn
}
