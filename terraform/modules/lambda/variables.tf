variable "function_name" {
  type        = string
  description = "Base name of the Lambda function"
}

variable "environment" {
  type        = string
  description = "Environment name (e.g., dev, staging, prod)"
}

variable "version_label" {
  type        = string
  description = "Version label for blue/green deployment"
  default     = "Blue"
}

variable "source_dir" {
  type        = string
  description = "Path to the lambda source code directory"
}