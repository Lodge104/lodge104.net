terraform {
  backend "s3" {
    bucket         = "lodge104-prod-tf"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lodge104-prod-lock"
    encrypt        = true
  }
}