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

variable "subnet_ids" {
  description = "List of subnet IDs for the ElastiCache subnet group"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs for the ElastiCache cluster"
  type        = list(string)
}

# Redis Configuration
variable "node_type" {
  description = "The instance class for the Redis nodes"
  type        = string
  default     = "cache.t3.micro"
}

variable "port" {
  description = "The port on which Redis accepts connections"
  type        = number
  default     = 6379
}

variable "engine_version" {
  description = "The version of Redis to use"
  type        = string
  default     = "7.0"
}

variable "parameter_group_family" {
  description = "The family of the ElastiCache parameter group"
  type        = string
  default     = "redis7.x"
}

# Cluster Configuration
variable "num_cache_clusters" {
  description = "The number of cache clusters (primary + replicas)"
  type        = number
  default     = 2
}

variable "automatic_failover_enabled" {
  description = "Enable automatic failover for the replication group"
  type        = bool
  default     = true
}

variable "multi_az_enabled" {
  description = "Enable Multi-AZ for the replication group"
  type        = bool
  default     = true
}

# Backup Configuration
variable "snapshot_retention_limit" {
  description = "The number of days to retain automatic snapshots"
  type        = number
  default     = 3
}

variable "snapshot_window" {
  description = "The daily time range for snapshots (UTC)"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "The weekly maintenance window"
  type        = string
  default     = "sun:05:00-sun:06:00"
}

# Security Configuration
variable "at_rest_encryption_enabled" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Enable encryption in transit"
  type        = bool
  default     = true
}

variable "auth_token_enabled" {
  description = "Enable Redis AUTH token"
  type        = bool
  default     = true
}

variable "auth_token" {
  description = "Redis AUTH token (password)"
  type        = string
  default     = ""
  sensitive   = true
}

# Other Configuration
variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "log_deliveries" {
  description = "Configuration for log deliveries"
  type = object({
    slow_log = bool
  })
  default = {
    slow_log = false
  }
}
