run "app_test" {
  command = plan

  module {
    source = "../../modules/app"
  }

  variables {
    name_prefix          = "AwsStudy"
    vpc_id               = "vpc-12345678"
    public_subnet_1a_id  = "subnet-11111111"
    public_subnet_1c_id  = "subnet-22222222"
    private_subnet_1a_id = "subnet-33333333"
    private_subnet_1c_id = "subnet-44444444"

    alb_security_group_id = "sg-11111111"
    ec2_security_group_id = "sg-22222222"
    rds_security_group_id = "sg-33333333"

    ami      = "ami-12345678"
    key_name = "test-key"

    rds_identifier               = "awsstudy-db"
    rds_db_name                  = "appdb"
    db_master_username           = "admin"
    rds_master_password_ssm_name = "/rds/master/password"

    alarm_email = "test@example.com"
  }

  assert {
    condition     = output.alb_type == "application"
    error_message = "ALB の type は application である必要があります。"
  }

  assert {
    condition     = output.alb_internal == false
    error_message = "ALB は internal = false である必要があります。"
  }

  assert {
    condition     = output.target_group_port == 8080
    error_message = "Target Group の port は 8080 である必要があります。"
  }

  assert {
    condition     = output.target_group_protocol == "HTTP"
    error_message = "Target Group の protocol は HTTP である必要があります。"
  }

  assert {
    condition     = output.target_group_target_type == "instance"
    error_message = "Target Group の target_type は instance である必要があります。"
  }

  assert {
    condition     = output.listener_port == 80
    error_message = "Listener の port は 80 である必要があります。"
  }

  assert {
    condition     = output.listener_protocol == "HTTP"
    error_message = "Listener の protocol は HTTP である必要があります。"
  }

  assert {
    condition     = output.listener_default_action_type == "forward"
    error_message = "Listener の default action は forward である必要があります。"
  }

  assert {
    condition     = output.ec2_instance_type == "t3.micro"
    error_message = "EC2 の instance_type は t3.micro である必要があります。"
  }

  assert {
    condition     = output.ec2_has_public_ip == true
    error_message = "EC2 は public IP を持つ設定である必要があります。"
  }

  assert {
    condition     = output.rds_instance_class == "db.t3.micro"
    error_message = "RDS の instance_class は db.t3.micro である必要があります。"
  }

  assert {
    condition     = output.rds_engine == "mysql"
    error_message = "RDS の engine は mysql である必要があります。"
  }

  assert {
    condition     = output.rds_publicly_accessible == false
    error_message = "RDS は publicly_accessible = false である必要があります。"
  }

  assert {
    condition     = output.rds_backup_retention_period == 7
    error_message = "RDS の backup_retention_period は 7 である必要があります。"
  }

  assert {
    condition     = output.sns_subscription_protocol == "email"
    error_message = "SNS Subscription の protocol は email である必要があります。"
  }

  assert {
    condition     = output.ec2_high_cpu_metric_name == "CPUUtilization"
    error_message = "EC2 高CPUアラームの metric_name は CPUUtilization である必要があります。"
  }

  assert {
    condition     = output.alb_5xx_metric_name == "HTTPCode_ELB_5XX_Count"
    error_message = "ALB 5xx アラームの metric_name は HTTPCode_ELB_5XX_Count である必要があります。"
  }

  assert {
    condition     = output.rds_low_storage_metric_name == "FreeStorageSpace"
    error_message = "RDS 低ストレージアラームの metric_name は FreeStorageSpace である必要があります。"
  }
}
