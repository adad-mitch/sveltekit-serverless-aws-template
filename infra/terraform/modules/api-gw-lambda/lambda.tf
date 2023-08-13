data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = var.lambda_source_path
  output_path = "${path.module}/tmp/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  filename      = "${path.module}/tmp/lambda.zip"
  function_name = "${var.resource_prefix}${var.lambda_name}"
  role          = aws_iam_role.lambda_role.arn
  handler       = var.lambda_handler_name
  runtime       = var.lambda_handler_runtime

  source_code_hash = data.archive_file.lambda.output_base64sha256
}

# There's a circular dependency between Lambda and API Gateway due to the ORIGIN
# environment variable required by the Node adapter - this ugly solution helps
# to decouple them.
resource "null_resource" "update_lambda_origin_env" {
  provisioner "local-exec" {
    command = <<-EOT
      aws lambda update-function-configuration \
      --profile ${var.aws_profile} \
      --region ${data.aws_region.current.name} \
      --function-name ${aws_lambda_function.lambda.function_name} \
      --environment Variables={ORIGIN=${trim(replace(aws_api_gateway_deployment.proxy_api_gw.invoke_url, "/[^/]*$", "$1"), "/")}}
    EOT
  }

  triggers = {
    api_gateway_deployment_id = aws_api_gateway_deployment.proxy_api_gw.id
  }
}
