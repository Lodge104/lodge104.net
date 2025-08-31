provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "lodge104-dev-tf"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "lodge104-dev-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = ">= 0.12"
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}