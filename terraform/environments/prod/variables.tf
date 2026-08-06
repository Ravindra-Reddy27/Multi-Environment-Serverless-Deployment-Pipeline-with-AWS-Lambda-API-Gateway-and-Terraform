variable "environment_name" {
  type        = string
  default     = "prod"
  description = "Target deployment environment"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for infrastructure resources"
}

variable "version_label" {
  type        = string
  default     = "Blue"
  description = "Application version label (e.g., Blue, Green)"
}