variable "project_name" {
  description = "The name of the project"
  type        = string
  default     = "wordpress"
}

variable "environment" {
  description = "The environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "domain_name" {
  description = "The domain name for the WordPress site"
  type        = string
  default     = ""
}

variable "create_hosted_zone" {
  description = "Whether to create a new hosted zone"
  type        = bool
  default     = true
}

variable "existing_zone_id" {
  description = "Existing Route53 hosted zone ID (if not creating new one)"
  type        = string
  default     = ""
}

variable "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  type        = string
}

variable "cloudfront_zone_id" {
  description = "CloudFront distribution hosted zone ID"
  type        = string
  default     = ""
}

variable "alb_domain_name" {
  description = "Application Load Balancer domain name"
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "Application Load Balancer hosted zone ID"
  type        = string
  default     = ""
}

variable "use_cloudfront" {
  description = "Whether to use CloudFront (true) or ALB (false) for DNS records"
  type        = bool
  default     = false
}