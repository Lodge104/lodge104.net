# Aurora Serverless Cluster Variables
variable "cluster_identifier" {
  description = "The cluster identifier for Aurora Serverless"
  type        = string
  default     = "wordpress-aurora"
}

variable "aurora_engine_version" {
  description = "The engine version for Aurora MySQL"
  type        = string
  default     = "5.7.mysql_aurora.2.10.1"
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
  default     = "wordpress"
}

variable "username" {
  description = "The master username for the database"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "The master password for the database"
  type        = string
  sensitive   = true
}

variable "security_group_id" {
  description = "The security group ID for the Aurora cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "backup_retention_period" {
  description = "The backup retention period in days"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "The daily time range for backups"
  type        = string
  default     = "03:00-04:00"
}

variable "maintenance_window" {
  description = "The weekly maintenance window"
  type        = string
  default     = "sun:04:00-sun:05:00"
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot when destroying the cluster"
  type        = bool
  default     = true
}

variable "deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

# Serverless scaling configuration
variable "auto_pause" {
  description = "Whether to enable automatic pause"
  type        = bool
  default     = true
}

variable "max_capacity" {
  description = "The maximum capacity for Aurora Serverless"
  type        = number
  default     = 4
}

variable "min_capacity" {
  description = "The minimum capacity for Aurora Serverless"
  type        = number
  default     = 1
}

variable "seconds_until_auto_pause" {
  description = "The time in seconds before Aurora Serverless is paused"
  type        = number
  default     = 300
}