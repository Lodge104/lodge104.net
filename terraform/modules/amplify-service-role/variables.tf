variable "app_id" {
  description = "Amplify Hosting app ID (e.g. d1c2x4zpjcxv7w)."
  type        = string

  validation {
    condition     = can(regex("^d[a-z0-9]+$", var.app_id))
    error_message = "app_id must be a valid Amplify app ID (starts with 'd')."
  }
}

variable "app_name" {
  description = "Human-readable app name, used in the role description."
  type        = string
}

variable "role_name" {
  description = "Name of the IAM service role."
  type        = string
}

variable "tags" {
  description = "Tags applied to the IAM role."
  type        = map(string)
  default     = {}
}
