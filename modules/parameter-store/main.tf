# AWS Systems Manager Parameter Store for Terraform Variables
# This module creates and manages parameters for team-shared configuration

# Create parameters for common configuration
resource "aws_ssm_parameter" "project_name" {
  name  = "/${var.project_name}/${var.environment}/project_name"
  type  = "String"
  value = var.project_name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "region" {
  name  = "/${var.project_name}/${var.environment}/region"
  type  = "String"
  value = var.region

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "domain_name" {
  count = var.domain_name != "" ? 1 : 0
  name  = "/${var.project_name}/${var.environment}/domain_name"
  type  = "String"
  value = var.domain_name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "vpc_cidr" {
  name  = "/${var.project_name}/${var.environment}/vpc_cidr"
  type  = "String"
  value = var.vpc_cidr

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Secure parameters for sensitive data
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}/${var.environment}/db_password"
  type  = "SecureString"
  value = var.db_password

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "redis_auth_token" {
  count = var.redis_auth_token != "" ? 1 : 0
  name  = "/${var.project_name}/${var.environment}/redis_auth_token"
  type  = "SecureString"
  value = var.redis_auth_token

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# CloudFront caching parameters
resource "aws_ssm_parameter" "cloudfront_price_class" {
  name  = "/${var.project_name}/${var.environment}/cloudfront_price_class"
  type  = "String"
  value = var.cloudfront_price_class

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "cloudfront_default_ttl" {
  name  = "/${var.project_name}/${var.environment}/cloudfront_default_ttl"
  type  = "String"
  value = tostring(var.cloudfront_default_ttl)

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# Instance configuration
resource "aws_ssm_parameter" "instance_type" {
  name  = "/${var.project_name}/${var.environment}/instance_type"
  type  = "String"
  value = var.instance_type

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_ssm_parameter" "desired_capacity" {
  name  = "/${var.project_name}/${var.environment}/desired_capacity"
  type  = "String"
  value = tostring(var.desired_capacity)

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
