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
  description = "The primary domain name for the certificate"
  type        = string
  default     = ""
}

variable "route53_zone_id" {
  description = "The Route53 hosted zone ID for DNS validation"
  type        = string
  default     = ""
}
