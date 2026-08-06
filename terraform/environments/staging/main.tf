terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "ravi-tf-state-123456"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  # Mandatory AWS Resource Tagging across all staging resources
  default_tags {
    tags = {
      Environment = var.environment_name
      Project     = "Serverless-BlueGreen-API"
      Owner       = "Ravi"
      ManagedBy   = "Terraform"
    }
  }
}

# 1. Instantiate Lambda Module
module "lambda" {
  source        = "../../modules/lambda"
  function_name = "hello-api"
  environment   = var.environment_name
  version_label = "Blue"
  source_dir    = "${path.module}/../../../lambda-src/hello_function"
}

# 2. Instantiate API Gateway Module
module "api_gateway" {
  source               = "../../modules/api-gateway"
  api_name             = "hello-api"
  environment          = var.environment_name
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
}

# 3. Security: API Key and Usage Plan Definition
resource "aws_api_gateway_api_key" "stage_key" {
  name = "hello-api-staging-key"
}

resource "aws_api_gateway_usage_plan" "stage_usage_plan" {
  name = "hello-api-staging-usage-plan"

  api_stages {
    api_id = module.api_gateway.api_id
    stage  = module.api_gateway.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "stage_key_assignment" {
  key_id        = aws_api_gateway_api_key.stage_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.stage_usage_plan.id
}

# Outputs for Verification
output "api_endpoint" {
  value       = module.api_gateway.invoke_url
  description = "Stage API Gateway invocation endpoint URL"
}

output "api_key_value" {
  value       = aws_api_gateway_api_key.stage_key.value
  sensitive   = true
  description = "API Key value for securing request calls"
}