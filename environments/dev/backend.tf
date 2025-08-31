terraform {
  backend "s3" {
    bucket         = "your-dev-bucket-name"
    key            = "dev/terraform.tfstate"
    region         = "your-region"
    dynamodb_table = "your-lock-table"
    encrypt        = true
  }
}