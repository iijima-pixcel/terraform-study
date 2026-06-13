run "iam_test" {
  command = plan

  module {
    source = "../../modules/iam/ec2_app_role"
  }

  variables {
    name_prefix                   = "AwsStudy"
    ansible_artifacts_bucket_name = "test-bucket"
    ssm_db_password_arn           = "arn:aws:ssm:ap-northeast-1:123456789012:parameter/test"
    ssm_kms_key_arn               = "arn:aws:kms:ap-northeast-1:123456789012:key/test"
  }

  assert {
    condition     = output.instance_profile_name != null
    error_message = "EC2用インスタンスプロファイルが作成されている必要があります。"
  }

  assert {
    condition     = output.ec2_role_name != null
    error_message = "EC2用IAMロールが作成されている必要があります。"
  }

  assert {
    condition     = output.ssm_managed_policy_arn == "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    error_message = "EC2用IAMロールにはAmazonSSMManagedInstanceCoreが付与されている必要があります。"
  }
}
