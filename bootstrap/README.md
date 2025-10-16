# Terraform S3 Backend Setup

This directory contains the bootstrap configuration to create the S3 bucket and DynamoDB table required for storing Terraform state remotely.

## Prerequisites

1. AWS CLI configured with appropriate permissions
2. Terraform installed
3. AWS credentials with permissions to create S3 buckets and DynamoDB tables

## Required AWS Permissions

The AWS user/role needs the following permissions:

- `s3:CreateBucket`
- `s3:ListBucket`
- `s3:GetObject`
- `s3:PutObject`
- `s3:DeleteObject`
- `s3:GetBucketVersioning`
- `s3:PutBucketVersioning`
- `s3:GetBucketEncryption`
- `s3:PutBucketEncryption`
- `s3:GetBucketPublicAccessBlock`
- `s3:PutBucketPublicAccessBlock`
- `dynamodb:CreateTable`
- `dynamodb:DescribeTable`
- `dynamodb:GetItem`
- `dynamodb:PutItem`
- `dynamodb:DeleteItem`

## Setup Instructions

### Step 1: Bootstrap the Backend Resources

1. Navigate to the bootstrap directory:

   ```bash
   cd bootstrap
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Review the plan:

   ```bash
   terraform plan
   ```

4. Apply the configuration to create the S3 buckets and DynamoDB tables:

   ```bash
   terraform apply
   ```

   This will create:

   - S3 bucket: `lodge104-terraform-state-dev` (for dev environment)
   - S3 bucket: `lodge104-terraform-state-prod` (for prod environment)
   - DynamoDB table: `lodge104-terraform-lock-dev` (for dev state locking)
   - DynamoDB table: `lodge104-terraform-lock-prod` (for prod state locking)

### Step 2: Configure Your Main Terraform Configuration

After the backend resources are created, you can use the remote backend in your main Terraform configurations.

For the **dev** environment:

```bash
cd ../environments/dev
terraform init
```

For the **prod** environment:

```bash
cd ../environments/prod
terraform init
```

Terraform will prompt you to migrate your existing state to the S3 backend. Answer "yes" to migrate.

## Backend Configuration Details

### Dev Environment Backend

- **Bucket**: `lodge104-terraform-state-dev`
- **Key**: `dev/terraform.tfstate`
- **Region**: `us-east-1`
- **DynamoDB Table**: `lodge104-terraform-lock-dev`
- **Encryption**: Enabled (AES256)

### Prod Environment Backend

- **Bucket**: `lodge104-terraform-state-prod`
- **Key**: `prod/terraform.tfstate`
- **Region**: `us-east-1`
- **DynamoDB Table**: `lodge104-terraform-lock-prod`
- **Encryption**: Enabled (AES256)

## Security Features

1. **State Encryption**: All state files are encrypted at rest using AES256
2. **Bucket Versioning**: Enabled to keep history of state changes
3. **Public Access Blocked**: All public access to the S3 buckets is blocked
4. **State Locking**: DynamoDB tables prevent concurrent modifications
5. **Point-in-Time Recovery**: Enabled on DynamoDB tables
6. **Lifecycle Protection**: Resources have `prevent_destroy` enabled

## Important Notes

⚠️ **WARNING**: Do not delete the S3 buckets or DynamoDB tables after they contain state files, as this will result in loss of your infrastructure state.

- The bootstrap configuration itself uses local state storage
- Keep the bootstrap state file safe, or consider using a separate backend for it
- Make sure your AWS credentials have sufficient permissions
- The bucket names must be globally unique - modify them if needed

## Customization

To customize the bucket names or table names, modify the variables in `variables.tf`:

```hcl
variable "dev_state_bucket_name" {
  default = "your-custom-dev-bucket-name"
}

variable "prod_state_bucket_name" {
  default = "your-custom-prod-bucket-name"
}
```

Remember to update the backend configurations in the respective environment directories if you change the names.

## Troubleshooting

### Bucket Already Exists Error

If you get an error that the bucket already exists, it means the bucket name is taken. Modify the bucket names in `variables.tf`.

### Access Denied Errors

Ensure your AWS credentials have the required permissions listed above.

### State Migration Issues

If you have issues migrating state, you can manually copy your local state file to S3 or start fresh (⚠️ only if you haven't deployed any resources yet).
