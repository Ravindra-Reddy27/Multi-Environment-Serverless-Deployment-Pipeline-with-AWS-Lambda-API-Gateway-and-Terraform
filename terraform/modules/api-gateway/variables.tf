variable "api_name" {
  type        = string
  description = "Name of the API Gateway"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "The Invoke ARN of the Lambda function (or alias)"
}

variable "lambda_function_name" {
  type        = string
  description = "The name of the Lambda function to grant permissions to"
}