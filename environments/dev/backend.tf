terraform {
  backend "s3" {
    bucket         = "awsstudy-dev-tfstate-a8f3k2"
    key            = "dev/terraform.tfstate"
    region         = "ap-northeast-1"
    dynamodb_table = "awsstudy-terraform-lock"
    encrypt        = true
  }
}
