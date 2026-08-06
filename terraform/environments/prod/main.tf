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
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region

  # Mandatory AWS Resource Tagging across all dev resources
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
  version_label = var.version_label
  source_dir    = "${path.module}/../../../lambda-src/hello_function"
}

# Define the Active (Live) Alias
resource "aws_lambda_alias" "live" {
  name             = "LIVE"
  description      = "The active production alias receiving traffic"
  function_name    = module.lambda.function_name
  function_version = module.lambda.version
  
  # Tell Terraform to let the CI/CD pipeline manage the version
  lifecycle {
    ignore_changes = [function_version]
  }
}

# Define the Inactive (Standby) Alias for future deployments
resource "aws_lambda_alias" "standby" {
  name             = "STANDBY"
  description      = "The inactive alias used for staging new deployments"
  function_name    = module.lambda.function_name
  function_version = module.lambda.version
  
  # Tell Terraform to let the CI/CD pipeline manage the version
  lifecycle {
    ignore_changes = [function_version]
  }
}

# 2. Instantiate API Gateway Module
module "api_gateway" {
  source               = "../../modules/api-gateway"
  api_name             = "hello-api"
  environment          = var.environment_name
  lambda_invoke_arn    = aws_lambda_alias.live.invoke_arn 
  lambda_function_name = module.lambda.function_name
  lambda_qualifier     = aws_lambda_alias.live.name # <--- Add this line!
}

# 3. Security: API Key and Usage Plan Definition
resource "aws_api_gateway_api_key" "prod_key" {
  name = "hello-api-${var.environment_name}-key"
}

resource "aws_api_gateway_usage_plan" "prod_usage_plan" {
  name = "hello-api-${var.environment_name}-usage-plan"

  api_stages {
    api_id = module.api_gateway.api_id
    stage  = module.api_gateway.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "prod_key_assignment" {
  key_id        = aws_api_gateway_api_key.prod_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.prod_usage_plan.id
}

# Outputs for Verification
output "api_endpoint" {
  value       = module.api_gateway.invoke_url
  description = "Prod API Gateway invocation endpoint URL"
}

output "api_key_value" {
  value       = aws_api_gateway_api_key.prod_key.value
  sensitive   = true
  description = "API Key value for securing request calls"
}