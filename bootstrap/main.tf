# Bootstrap configuration to create S3 bucket and DynamoDB table for Terraform state
# This should be run first before configuring the backend

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  required_version = ">= 0.12"
}

provider "aws" {
  region = var.aws_region
}

# Create the backend resources for dev environment
module "dev_backend" {
  source = "../modules/terraform-backend"

  state_bucket_name = var.dev_state_bucket_name
  lock_table_name   = var.dev_lock_table_name
  environment       = "dev"
  project_name      = var.project_name
}

# Create the backend resources for prod environment
module "prod_backend" {
  source = "../modules/terraform-backend"

  state_bucket_name = var.prod_state_bucket_name
  lock_table_name   = var.prod_lock_table_name
  environment       = "prod"
  project_name      = var.project_name
}