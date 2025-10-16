terraform {
  backend "s3" {
    bucket         = "lodge104-terraform-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lodge104-terraform-lock-prod"
    encrypt        = true
  }
}