#!/bin/bash
# AWS SSO Helper Script for Terraform
# This script exports AWS SSO credentials as environment variables for Terraform

set -e

PROFILE_NAME="AdministratorAccess-423971488961"
REGION="us-east-1"

echo "🔐 Getting AWS SSO credentials for profile: $PROFILE_NAME"

# Check if we need to login first
if ! aws sts get-caller-identity --profile $PROFILE_NAME >/dev/null 2>&1; then
    echo "⚠️  SSO session expired or not logged in. Running: aws sso login --profile $PROFILE_NAME"
    aws sso login --profile $PROFILE_NAME
fi

echo "✅ Exporting AWS credentials as environment variables..."

# Export credentials
eval "$(aws configure export-credentials --profile $PROFILE_NAME --format env)"

echo "✅ AWS credentials exported successfully!"

# Verify the credentials work
echo "� Verifying credentials..."
aws sts get-caller-identity

echo "✅ All set! You're authenticated as: $(aws sts get-caller-identity --query 'Arn' --output text)"

# Check and create required resources
echo ""
echo "🔧 Checking required AWS resources..."

# Check/create dev S3 bucket
if aws s3api head-bucket --bucket lodge104-dev-tf >/dev/null 2>&1; then
    echo "✅ Dev S3 bucket exists: lodge104-dev-tf"
else
    echo "📦 Creating dev S3 bucket: lodge104-dev-tf"
    aws s3 mb s3://lodge104-dev-tf --region $REGION
fi

# Check/create prod S3 bucket
if aws s3api head-bucket --bucket lodge104-prod-tf >/dev/null 2>&1; then
    echo "✅ Prod S3 bucket exists: lodge104-prod-tf"
else
    echo "� Creating prod S3 bucket: lodge104-prod-tf"
    aws s3 mb s3://lodge104-prod-tf --region $REGION
fi

# Check/create dev DynamoDB table
if aws dynamodb describe-table --table-name lodge104-dev-lock --region $REGION >/dev/null 2>&1; then
    echo "✅ Dev DynamoDB table exists: lodge104-dev-lock"
else
    echo "🗄️  Creating dev DynamoDB table: lodge104-dev-lock"
    aws dynamodb create-table \
        --table-name lodge104-dev-lock \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region $REGION >/dev/null
    echo "⏳ Waiting for table to be active..."
    aws dynamodb wait table-exists --table-name lodge104-dev-lock --region $REGION
fi

# Check/create prod DynamoDB table
if aws dynamodb describe-table --table-name lodge104-prod-lock --region $REGION >/dev/null 2>&1; then
    echo "✅ Prod DynamoDB table exists: lodge104-prod-lock"
else
    echo "�️  Creating prod DynamoDB table: lodge104-prod-lock"
    aws dynamodb create-table \
        --table-name lodge104-prod-lock \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region $REGION >/dev/null
    echo "⏳ Waiting for table to be active..."
    aws dynamodb wait table-exists --table-name lodge104-prod-lock --region $REGION
fi

echo ""
echo "🚀 You can now run Terraform commands:"
echo "   cd environments/dev && terraform plan"
echo "   cd environments/prod && terraform plan"
echo ""
echo "📝 Note: These credentials expire in 1 hour. Re-run this script if they expire."
