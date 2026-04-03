terraform {
  backend "s3" {
    bucket         = "iijima-terraform-state"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "iijima-terraform-lock"
    encrypt        = true
  }
}
