terraform {
  backend "s3" {
    bucket         = "lodge104-dev-tf"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lodge104-dev-lock"
    encrypt        = true
  }
}