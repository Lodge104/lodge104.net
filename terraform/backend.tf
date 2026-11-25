# Remote state in the account-wide Lodge 104 Terraform state bucket
# (versioned, SSE-encrypted, public access blocked). Uses S3-native state
# locking (`use_lockfile`), which replaces the deprecated DynamoDB lock table.

terraform {
  backend "s3" {
    bucket       = "lodge104-terraform-state"
    key          = "lodge104.net/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
