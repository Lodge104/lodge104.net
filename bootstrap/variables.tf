variable "aws_region" {
  description = "AWS region for the backend resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "lodge104"
}

variable "dev_state_bucket_name" {
  description = "Name of the S3 bucket for dev environment Terraform state"
  type        = string
  default     = "lodge104-terraform-state-dev"
}

variable "dev_lock_table_name" {
  description = "Name of the DynamoDB table for dev environment state locking"
  type        = string
  default     = "lodge104-terraform-lock-dev"
}

variable "prod_state_bucket_name" {
  description = "Name of the S3 bucket for prod environment Terraform state"
  type        = string
  default     = "lodge104-terraform-state-prod"
}

variable "prod_lock_table_name" {
  description = "Name of the DynamoDB table for prod environment state locking"
  type        = string
  default     = "lodge104-terraform-lock-prod"
}