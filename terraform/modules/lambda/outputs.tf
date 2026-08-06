output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "arn" {
  value = aws_lambda_function.this.arn
}

output "version" {
  value       = aws_lambda_function.this.version
  description = "The published version of the Lambda function"
}