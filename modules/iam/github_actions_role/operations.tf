data "aws_iam_policy_document" "github_actions_operations_policy" {
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
    sid    = "CloudWatchAlarmsAwsStudy"
    effect = "Allow"

    actions = [
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListTagsForResource",
      "cloudwatch:TagResource",
      "cloudwatch:UntagResource",
      "cloudwatch:EnableAlarmActions",
      "cloudwatch:DisableAlarmActions"
    ]

    resources = [
      "arn:aws:cloudwatch:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:alarm:${var.name_prefix}-*"
    ]
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
    sid    = "SnsTopicAwsStudy"
    effect = "Allow"

    actions = [
      "sns:CreateTopic",
      "sns:DeleteTopic",
      "sns:Subscribe",
      "sns:Unsubscribe",
      "sns:GetSubscriptionAttributes",
      "sns:SetSubscriptionAttributes",
      "sns:SetTopicAttributes",
      "sns:GetTopicAttributes",
      "sns:TagResource",
      "sns:UntagResource",
      "sns:ListTagsForResource"
    ]

    resources = [
      "arn:aws:sns:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${var.name_prefix}-*"
    ]
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
    sid    = "ReadSsmCommandResult"
    effect = "Allow"

    actions = [
      "ssm:GetCommandInvocation",
      "ssm:ListCommandInvocations",
      "ssm:ListCommands"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowRunShellScriptDocument"
    effect = "Allow"

    actions = [
      "ssm:SendCommand"
    ]

    resources = [
      "arn:aws:ssm:${data.aws_region.current.id}::document/AWS-RunShellScript"
    ]
  }

  statement {
    sid    = "AllowSendCommandToTaggedEc2"
    effect = "Allow"

    actions = [
      "ssm:SendCommand"
    ]

    resources = [
      "arn:aws:ec2:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:instance/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "ssm:resourceTag/Project"
      values   = [var.project]
    }
  }

  statement {
    sid    = "ManageSsmRunCommandLogGroup"
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:PutRetentionPolicy",
      "logs:*Tag*"
    ]

    resources = [
      "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:SSMRunCommandLogs",
      "arn:aws:logs:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:log-group:SSMRunCommandLogs:*"
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
    sid    = "UploadAnsibleArtifactsToS3"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${var.ansible_artifacts_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "github_actions_operations" {
  name   = "${var.name_prefix}-GitHubActions-Operations"
  policy = data.aws_iam_policy_document.github_actions_operations_policy.json
}

resource "aws_iam_role_policy_attachment" "github_actions_operations" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_actions_operations.arn
}
