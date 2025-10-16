terraform {
  backend "s3" {
    bucket         = "lodge104-terraform-state-dev"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lodge104-terraform-lock-dev"
    encrypt        = true
  }
}