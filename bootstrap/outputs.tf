output "dev_state_bucket_name" {
  description = "Name of the S3 bucket for dev environment Terraform state"
  value       = module.dev_backend.state_bucket_name
}

output "dev_lock_table_name" {
  description = "Name of the DynamoDB table for dev environment state locking"
  value       = module.dev_backend.lock_table_name
}

output "prod_state_bucket_name" {
  description = "Name of the S3 bucket for prod environment Terraform state"
  value       = module.prod_backend.state_bucket_name
}

output "prod_lock_table_name" {
  description = "Name of the DynamoDB table for prod environment state locking"
  value       = module.prod_backend.lock_table_name
}