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
  description = "VPC ID where the ALB will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = false
}

variable "health_check_path" {
  description = "The path for ALB health checks"
  type        = string
  default     = "/"
}

variable "ssl_certificate_arn" {
  description = "ARN of the SSL certificate for HTTPS listener"
  type        = string
  default     = ""
}

variable "ssl_policy" {
  description = "SSL policy for the HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "enable_https_backend" {
  description = "Enable HTTPS communication to backend instances"
  type        = bool
  default     = false
}

variable "backend_port" {
  description = "Port for backend communication (80 for HTTP, 443 for HTTPS)"
  type        = number
  default     = 80
}

variable "backend_protocol" {
  description = "Protocol for backend communication (HTTP or HTTPS)"
  type        = string
  default     = "HTTP"
}