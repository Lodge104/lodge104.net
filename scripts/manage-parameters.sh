#!/bin/bash

# Parameter Store Management Script
# This script helps teams manage shared Terraform variables in AWS Parameter Store

set -e

PROJECT_NAME=${1:-"wordpress"}
ENVIRONMENT=${2:-"prod"}
AWS_REGION=${3:-"us-east-1"}

echo "🚀 Parameter Store Management for ${PROJECT_NAME} (${ENVIRONMENT})"
echo "================================================="

# Function to create or update a parameter
create_parameter() {
    local name=$1
    local value=$2
    local type=${3:-"String"}
    local description=$4
    
    echo "📝 Setting parameter: $name"
    
    aws ssm put-parameter \
        --region "$AWS_REGION" \
        --name "/${PROJECT_NAME}/${ENVIRONMENT}/${name}" \
        --value "$value" \
        --type "$type" \
        --description "$description" \
        --overwrite \
        --tags '[{"Key":"Environment","Value":"'$ENVIRONMENT'"},{"Key":"ManagedBy","Value":"TeamScript"}]' \
        >/dev/null 2>&1
    
    echo "✅ Parameter /${PROJECT_NAME}/${ENVIRONMENT}/${name} set successfully"
}

# Function to get a parameter
get_parameter() {
    local name=$1
    local decrypt=${2:-false}
    
    local decrypt_flag=""
    if [ "$decrypt" = "true" ]; then
        decrypt_flag="--with-decryption"
    fi
    
    aws ssm get-parameter \
        --region "$AWS_REGION" \
        --name "/${PROJECT_NAME}/${ENVIRONMENT}/${name}" \
        $decrypt_flag \
        --query 'Parameter.Value' \
        --output text 2>/dev/null || echo "Parameter not found"
}

# Function to list all parameters
list_parameters() {
    echo "📋 Current parameters for ${PROJECT_NAME}/${ENVIRONMENT}:"
    echo "================================================="
    
    aws ssm get-parameters-by-path \
        --region "$AWS_REGION" \
        --path "/${PROJECT_NAME}/${ENVIRONMENT}/" \
        --query 'Parameters[].{Name:Name,Type:Type,LastModified:LastModifiedDate}' \
        --output table 2>/dev/null || echo "No parameters found"
}

# Function to setup initial parameters
setup_initial_parameters() {
    echo "🏗️  Setting up initial parameters..."
    
    # Prompt for values
    read -p "Enter domain name (e.g., lodge104.net): " domain_name
    read -p "Enter VPC CIDR (e.g., 10.0.0.0/16): " vpc_cidr
    read -s -p "Enter database password: " db_password
    echo
    read -s -p "Enter Redis auth token: " redis_auth_token
    echo
    read -p "Enter instance type (e.g., t3.micro): " instance_type
    read -p "Enter desired capacity (e.g., 2): " desired_capacity
    read -p "Enter CloudFront price class (PriceClass_100/200/All): " cloudfront_price_class
    read -p "Enter CloudFront default TTL (e.g., 86400): " cloudfront_default_ttl
    
    # Create parameters
    create_parameter "project_name" "$PROJECT_NAME" "String" "Project name"
    create_parameter "region" "$AWS_REGION" "String" "AWS region"
    create_parameter "domain_name" "$domain_name" "String" "Primary domain name"
    create_parameter "vpc_cidr" "$vpc_cidr" "String" "VPC CIDR block"
    create_parameter "db_password" "$db_password" "SecureString" "Database password"
    create_parameter "redis_auth_token" "$redis_auth_token" "SecureString" "Redis authentication token"
    create_parameter "instance_type" "$instance_type" "String" "EC2 instance type"
    create_parameter "desired_capacity" "$desired_capacity" "String" "Auto Scaling desired capacity"
    create_parameter "cloudfront_price_class" "$cloudfront_price_class" "String" "CloudFront price class"
    create_parameter "cloudfront_default_ttl" "$cloudfront_default_ttl" "String" "CloudFront default TTL"
    
    echo "✅ Initial parameters setup complete!"
}

# Function to generate Terraform command
generate_terraform_command() {
    echo "🔧 To use Parameter Store with Terraform, run:"
    echo "================================================="
    echo "terraform apply -var=\"use_parameter_store=true\" -var=\"project_name=$PROJECT_NAME\" -var=\"environment=$ENVIRONMENT\""
    echo ""
    echo "Or add to your terraform.tfvars:"
    echo "use_parameter_store = true"
    echo "project_name = \"$PROJECT_NAME\""
    echo "environment = \"$ENVIRONMENT\""
}

# Main menu
case "${4:-menu}" in
    "setup")
        setup_initial_parameters
        ;;
    "list")
        list_parameters
        ;;
    "get")
        if [ -z "$5" ]; then
            echo "Usage: $0 $PROJECT_NAME $ENVIRONMENT $AWS_REGION get <parameter_name> [decrypt]"
            exit 1
        fi
        decrypt=${6:-false}
        echo "Value: $(get_parameter "$5" "$decrypt")"
        ;;
    "terraform")
        generate_terraform_command
        ;;
    *)
        echo "Usage: $0 <project_name> <environment> <aws_region> <command>"
        echo ""
        echo "Commands:"
        echo "  setup     - Interactive setup of initial parameters"
        echo "  list      - List all parameters"
        echo "  get       - Get a specific parameter value"
        echo "  terraform - Show Terraform command to use Parameter Store"
        echo ""
        echo "Examples:"
        echo "  $0 wordpress prod us-east-1 setup"
        echo "  $0 wordpress prod us-east-1 list"
        echo "  $0 wordpress prod us-east-1 get db_password true"
        echo "  $0 wordpress prod us-east-1 terraform"
        ;;
esac
