#!/bin/bash

# Terraform S3 Backend Setup Script
# This script automates the setup of S3 buckets and DynamoDB tables for Terraform state storage

set -e

echo "🚀 Setting up Terraform S3 Backend for Lodge104.net"
echo "=================================================="

# Check if AWS CLI is configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "❌ AWS CLI is not configured or you don't have valid credentials"
    echo "Please run 'aws configure' or set up your AWS credentials"
    exit 1
fi

echo "✅ AWS credentials verified"

# Get current AWS account and region
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region || echo "us-east-1")

echo "📍 AWS Account: $AWS_ACCOUNT"
echo "📍 AWS Region: $AWS_REGION"

# Navigate to bootstrap directory
cd "$(dirname "$0")/../bootstrap"

echo ""
echo "🔧 Initializing Terraform..."
terraform init

echo ""
echo "📋 Planning Terraform deployment..."
terraform plan

echo ""
read -p "🤔 Do you want to proceed with creating the backend resources? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🚀 Creating S3 buckets and DynamoDB tables..."
    terraform apply -auto-approve
    
    echo ""
    echo "✅ Backend resources created successfully!"
    echo ""
    echo "📝 Backend Configuration Summary:"
    echo "================================="
    terraform output
    
    echo ""
    echo "🎉 Setup complete! You can now use the S3 backend in your environments."
    echo ""
    echo "Next steps:"
    echo "1. cd ../environments/dev && terraform init (for dev environment)"
    echo "2. cd ../environments/prod && terraform init (for prod environment)"
    echo ""
    echo "Terraform will ask if you want to migrate existing state - answer 'yes' if you have existing state files."
else
    echo "❌ Deployment cancelled."
    exit 1
fi