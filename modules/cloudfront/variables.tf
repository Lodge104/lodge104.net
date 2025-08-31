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

variable "alb_domain_name" {
  description = "The domain name of the ALB origin"
  type        = string
}

variable "domain_name" {
  description = "The domain name for the CloudFront distribution (optional)"
  type        = string
  default     = ""
}

variable "ssl_certificate_arn" {
  description = "The ARN of the SSL certificate (leave empty for default certificate)"
  type        = string
  default     = ""
}

variable "origin_protocol_policy" {
  description = "The origin protocol policy for the CloudFront distribution"
  type        = string
  default     = "https-only"
  validation {
    condition     = contains(["http-only", "https-only", "match-viewer"], var.origin_protocol_policy)
    error_message = "Origin protocol policy must be one of: http-only, https-only, match-viewer."
  }
}

variable "geo_restriction_type" {
  description = "The method to restrict distribution of your content by country"
  type        = string
  default     = "none"
  validation {
    condition     = contains(["none", "whitelist", "blacklist"], var.geo_restriction_type)
    error_message = "Geo restriction type must be one of: none, whitelist, blacklist."
  }
}

variable "geo_restriction_locations" {
  description = "The ISO 3166-1-alpha-2 codes for which you want CloudFront to either allow or block"
  type        = list(string)
  default     = []
}

# CloudFront Caching Configuration Variables
variable "price_class" {
  description = "CloudFront distribution price class"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition     = contains(["PriceClass_All", "PriceClass_200", "PriceClass_100"], var.price_class)
    error_message = "Price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

variable "default_ttl" {
  description = "Default TTL for CloudFront cache behavior (seconds)"
  type        = number
  default     = 86400
}

variable "max_ttl" {
  description = "Maximum TTL for CloudFront cache behavior (seconds)"
  type        = number
  default     = 31536000
}

variable "min_ttl" {
  description = "Minimum TTL for CloudFront cache behavior (seconds)"
  type        = number
  default     = 0
}

variable "admin_ttl" {
  description = "TTL for WordPress admin areas (seconds)"
  type        = number
  default     = 0
}

variable "compress" {
  description = "Whether to enable CloudFront compression"
  type        = bool
  default     = true
}

variable "query_string" {
  description = "Whether to forward query strings to origin"
  type        = bool
  default     = true
}

variable "cookies_forward" {
  description = "Cookie forwarding behavior (none, whitelist, all)"
  type        = string
  default     = "whitelist"
  validation {
    condition     = contains(["none", "whitelist", "all"], var.cookies_forward)
    error_message = "Cookies forward must be one of: none, whitelist, all."
  }
}