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
  description = "List of subnet IDs where EFS mount targets will be created"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for EFS mount targets"
  type        = string
}

variable "performance_mode" {
  description = "The performance mode for the EFS file system. Can be either 'generalPurpose' or 'maxIO'"
  type        = string
  default     = "generalPurpose"
}

variable "throughput_mode" {
  description = "The throughput mode for the EFS file system. Can be either 'bursting' or 'provisioned'"
  type        = string
  default     = "bursting"
}

variable "provisioned_throughput_in_mibps" {
  description = "The provisioned throughput in MiB/s when using provisioned throughput mode"
  type        = number
  default     = null
}