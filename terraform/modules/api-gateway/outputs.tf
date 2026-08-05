output "api_id" {
  value = aws_api_gateway_rest_api.this.id
}

output "stage_name" {
  value = aws_api_gateway_stage.this.stage_name
}

output "invoke_url" {
  value = "${aws_api_gateway_stage.this.invoke_url}/hello"
}