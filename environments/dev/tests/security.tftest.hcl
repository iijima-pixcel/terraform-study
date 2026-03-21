run "security_test" {
  command = plan

  module {
    source = "../../modules/security"
  }

  variables {
    vpc_id                = "vpc-12345678"
    cidr_ip_from_internet = "36.8.0.45/32"
    name_prefix           = "AwsStudy"
  }

  assert {
    condition     = output.alb_security_group_name == "AwsStudyAlbSecurityGroup"
    error_message = "ALB Security Group の名前が仕様どおりではありません。"
  }

  assert {
    condition     = output.ec2_security_group_name == "AwsStudyEc2SecurityGroup"
    error_message = "EC2 Security Group の名前が仕様どおりではありません。"
  }

  assert {
    condition     = output.rds_security_group_name == "AwsStudyRdsSecurityGroup"
    error_message = "RDS Security Group の名前が仕様どおりではありません。"
  }

  assert {
    condition     = output.has_alb_http_rule
    error_message = "ALB Security Group は Internet からの HTTP(80) を許可する必要があります。"
  }

  assert {
    condition     = output.has_ec2_app_rule
    error_message = "EC2 Security Group は ALB からのアプリ通信(8080)を許可する必要があります。"
  }

  assert {
    condition     = output.has_ec2_ssh_rule
    error_message = "EC2 Security Group は指定CIDRからの SSH(22) を許可する必要があります。"
  }

  assert {
    condition     = output.has_ec2_ssh_from_any == false
    error_message = "EC2 の SSH が 0.0.0.0/0 に公開されています（危険）"
  }

  assert {
    condition     = output.has_rds_mysql_rule
    error_message = "RDS Security Group は EC2 からの MySQL(3306) を許可する必要があります。"
  }
}
