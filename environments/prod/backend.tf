terraform {
  backend "s3" {
    bucket         = "your-prod-bucket-name"
    key            = "terraform/prod/terraform.tfstate"
    region         = "your-region"
    dynamodb_table = "your-dynamodb-table"
    encrypt        = true
  }
}