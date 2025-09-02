#!/bin/bash

# Quick AWS Credentials Loader
# Source this file to load AWS credentials: source scripts/aws-env.sh

# Check if .env file exists
if [ -f "/workspaces/lodge104.net/.env" ]; then
    echo "Loading AWS credentials from .env file..."
    source /workspaces/lodge104.net/.env
    echo "✅ AWS credentials loaded!"
    echo "   AWS_PROFILE: $AWS_PROFILE"
    echo "   AWS_REGION: $AWS_REGION"
    
    # Verify credentials
    if aws sts get-caller-identity >/dev/null 2>&1; then
        ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null)
        echo "   Account: $ACCOUNT ✅"
    else
        echo "   ❌ Credentials appear to be expired. Run: source scripts/load-aws-credentials.sh"
    fi
else
    echo "❌ No .env file found. Please run: source scripts/load-aws-credentials.sh"
fi
