variable "environment_name" {
  type        = string
  default     = "dev"
  description = "Target deployment environment"
}

variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region for infrastructure resources"
}