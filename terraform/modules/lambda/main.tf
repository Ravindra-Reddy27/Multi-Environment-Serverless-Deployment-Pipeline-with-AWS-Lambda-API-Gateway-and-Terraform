# Package the Python code into a zip file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/lambda_payload.zip"
}

# Define the least-privilege IAM Role
resource "aws_iam_role" "lambda_exec" {
  name = "${var.function_name}-exec-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic execution policy for CloudWatch logging
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Provision the Lambda Function
resource "aws_lambda_function" "this" {
  function_name    = "${var.function_name}-${var.environment}"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "app.lambda_handler"
  runtime          = "python3.9"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      ENVIRONMENT = var.environment
      VERSION     = var.version_label
    }
  }

  tags = {
    Environment = var.environment
  }
}

# Explicitly create the CloudWatch Log Group for proper retention
resource "aws_cloudwatch_log_group" "lambda_log" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 14
  tags = {
    Environment = var.environment
  }
}