data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

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
    Name = "${var.name_prefix}-EC2-Role"
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.name_prefix}-EC2-Instance-Profile"
  role = aws_iam_role.ec2.name
}

data "aws_iam_policy_document" "ec2_policy" {
  statement {
    sid    = "ReadAnsibleArtifactsFromS3"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.ansible_artifacts_bucket_name}/*"
    ]
  }

  statement {
    sid    = "ListAnsibleArtifactsBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.ansible_artifacts_bucket_name}"
    ]
  }
  statement {
    sid    = "ReadSsmParameter"
    effect = "Allow"

    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]

    resources = [var.ssm_db_password_arn]
  }

  statement {
    sid    = "DecryptViaSsm"
    effect = "Allow"

    actions = [
      "kms:Decrypt"
    ]

    resources = [var.ssm_kms_key_arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ssm.${data.aws_region.current.region}.amazonaws.com"]
    }
  }

  statement {
    sid    = "WriteSsmLogsToSpecificLogGroup"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:SSMRunCommandLogs:*"
    ]
  }
}

resource "aws_iam_policy" "ec2_policy" {
  name   = "${var.name_prefix}-EC2-Policy"
  policy = data.aws_iam_policy_document.ec2_policy.json
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_attach" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_managed_instance_core" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
