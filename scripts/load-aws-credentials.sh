#!/bin/bash

# AWS Credentials Loading Script
# This script loads AWS credentials from SSO and exports them as environment variables

set -e

PROFILE_NAME="AdministratorAccess-423971488961"
SSO_START_URL="https://ocscouts.awsapps.com/start"
SSO_REGION="us-east-1"
ACCOUNT_ID="423971488961"
ROLE_NAME="AdministratorAccess"

echo "Loading AWS credentials for profile: $PROFILE_NAME"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed"
    exit 1
fi

# Check if profile exists, if not create it
if ! aws configure list-profiles | grep -q "$PROFILE_NAME"; then
    echo "Creating AWS SSO profile: $PROFILE_NAME"
    aws configure set sso_start_url "$SSO_START_URL" --profile "$PROFILE_NAME"
    aws configure set sso_region "$SSO_REGION" --profile "$PROFILE_NAME"
    aws configure set sso_account_id "$ACCOUNT_ID" --profile "$PROFILE_NAME"
    aws configure set sso_role_name "$ROLE_NAME" --profile "$PROFILE_NAME"
    aws configure set region us-east-1 --profile "$PROFILE_NAME"
fi

# Login to AWS SSO
echo "Logging in to AWS SSO..."
aws sso login --profile "$PROFILE_NAME"

# Get temporary credentials
echo "Retrieving temporary credentials..."
CREDENTIALS=$(aws sts get-caller-identity --profile "$PROFILE_NAME" --query 'Account' --output text 2>/dev/null || echo "")

if [ -z "$CREDENTIALS" ]; then
    echo "Error: Failed to retrieve credentials. Re-attempting SSO login..."
    aws sso login --profile "$PROFILE_NAME" --no-browser
fi

# Export AWS credentials as environment variables
echo "Exporting AWS credentials as environment variables..."

# Get the actual credentials from the SSO cache
CREDS=$(aws configure export-credentials --profile "$PROFILE_NAME" --format env 2>/dev/null || echo "")

if [ -n "$CREDS" ]; then
    # Parse and export the credentials
    eval "$CREDS"
    
    # Also set the profile for tools that prefer it
    export AWS_PROFILE="$PROFILE_NAME"
    
    echo "✅ AWS credentials loaded successfully!"
    echo "   AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID:0:20}..."
    echo "   AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY:0:10}..."
    echo "   AWS_SESSION_TOKEN: ${AWS_SESSION_TOKEN:0:20}..."
    echo "   AWS_PROFILE: $AWS_PROFILE"
    
    # Verify credentials work
    ACCOUNT=$(aws sts get-caller-identity --query 'Account' --output text 2>/dev/null || echo "")
    if [ "$ACCOUNT" = "$ACCOUNT_ID" ]; then
        echo "   Account ID: $ACCOUNT ✅"
    else
        echo "   Warning: Account verification failed"
    fi
else
    echo "❌ Failed to export credentials. Falling back to profile-based authentication..."
    export AWS_PROFILE="$PROFILE_NAME"
fi

# Create a credentials file for Terraform
CREDENTIALS_FILE="$HOME/.aws/credentials.env"
cat > "$CREDENTIALS_FILE" << EOF
# AWS Credentials Environment Variables
# Source this file to load credentials: source ~/.aws/credentials.env
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
export AWS_PROFILE="$AWS_PROFILE"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_REGION="us-east-1"
EOF

echo "💾 Credentials saved to: $CREDENTIALS_FILE"
echo "   To load in new shell: source $CREDENTIALS_FILE"

# Also save to a .env file in the project root
PROJECT_ENV_FILE="/workspaces/lodge104.net/.env"
cat > "$PROJECT_ENV_FILE" << EOF
# AWS Credentials for Terraform
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN=$AWS_SESSION_TOKEN
AWS_PROFILE=$AWS_PROFILE
AWS_DEFAULT_REGION=us-east-1
AWS_REGION=us-east-1
EOF

echo "💾 Project credentials saved to: $PROJECT_ENV_FILE"
