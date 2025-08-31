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

variable "vpc_id" {
  description = "The VPC ID where the security groups will be created"
  type        = string
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}