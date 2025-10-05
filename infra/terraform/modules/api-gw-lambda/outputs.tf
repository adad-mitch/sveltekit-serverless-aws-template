output "lambda_arn" {
  description = "The ARN of the AWS Lambda function."
  value       = aws_lambda_function.lambda.arn
}

output "lambda_last_modified" {
  description = "Date/time that the Lambda function was last modified."
  value       = aws_lambda_function.lambda.last_modified
}

output "lambda_source_code_size" {
  description = "The size, in bytes, of the Lambda function's .zip file."
  value       = aws_lambda_function.lambda.source_code_size
}

output "api_id" {
  description = "The ID of the AWS API Gateway REST API."
  value       = aws_api_gateway_rest_api.proxy_api_gw.id
}

output "api_arn" {
  description = "The ARN of the AWS API Gateway REST API."
  value       = aws_api_gateway_rest_api.proxy_api_gw.arn
}

output "api_created_date" {
  description = "The creation date of the AWS API Gateway REST API."
  value       = aws_api_gateway_rest_api.proxy_api_gw.arn
}

output "api_invoke_url" {
  description = "The invocation URL of the AWS API Gateway, pointing to the provided stage."
  value       = aws_api_gateway_stage.proxy_api_gw.invoke_url
}

output "api_key" {
  description = "The API key for the AWS API Gateway REST API. When used, this should be sent in an `x-api-key` header."
  value       = random_password.api_key.result
  sensitive   = true
}
