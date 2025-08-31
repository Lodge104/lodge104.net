variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment (dev, prod, etc.)"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the WordPress site"
  type        = string
  default     = ""
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "redis_auth_token" {
  description = "Redis AUTH token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "cloudfront_price_class" {
  description = "CloudFront distribution price class"
  type        = string
}

variable "cloudfront_default_ttl" {
  description = "Default TTL for CloudFront cache behavior"
  type        = number
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
}

variable "desired_capacity" {
  description = "The desired number of EC2 instances"
  type        = number
}
