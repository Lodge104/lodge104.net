#!/bin/bash

# AWS SSO Credentials Helper for Terraform
# This script exports AWS credentials from SSO for use with Terraform

set -e

echo "🔐 Setting up AWS credentials for Terraform..."

# Check if AWS CLI is configured
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo "❌ AWS CLI is not configured or you don't have valid credentials"
    echo "Please run 'aws sso login --profile default' first"
    exit 1
fi

echo "✅ AWS SSO session is active"

# Export credentials for Terraform
echo "📤 Exporting AWS credentials as environment variables..."

# Get temporary credentials
CREDS=$(aws configure export-credentials --profile default 2>/dev/null)

if [ $? -ne 0 ]; then
    echo "❌ Failed to export credentials. Please run 'aws sso login --profile default'"
    exit 1
fi

# Parse JSON and export variables
export AWS_ACCESS_KEY_ID=$(echo $CREDS | jq -r '.AccessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $CREDS | jq -r '.SecretAccessKey')
export AWS_SESSION_TOKEN=$(echo $CREDS | jq -r '.SessionToken')
export AWS_DEFAULT_REGION="us-east-1"

echo "✅ AWS credentials exported successfully"
echo "📍 Region: $AWS_DEFAULT_REGION"
echo "📍 Account: $(aws sts get-caller-identity --query Account --output text)"

# Create a .env file for easy sourcing
cat > .env << EOF
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
export AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION"
EOF

echo ""
echo "🎯 You can now run Terraform commands!"
echo ""
echo "💡 For future sessions, you can:"
echo "   1. Run this script again: ./scripts/setup-aws-creds.sh"
echo "   2. Or source the .env file: source .env"
echo "   3. Or run: aws sso login --profile default && ./scripts/setup-aws-creds.sh"
echo ""
echo "⏰ Note: These credentials expire. Re-run this script if you get authentication errors."