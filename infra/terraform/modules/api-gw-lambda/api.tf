resource "aws_api_gateway_rest_api" "proxy_api_gw" {
  name        = "${var.resource_prefix}${var.api_gateway_name}"
  description = var.api_gateway_description
}

resource "aws_api_gateway_method" "root_proxy" {
  rest_api_id      = aws_api_gateway_rest_api.proxy_api_gw.id
  resource_id      = aws_api_gateway_rest_api.proxy_api_gw.root_resource_id
  api_key_required = true
  http_method      = "ANY"
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "root_proxy" {
  rest_api_id = aws_api_gateway_rest_api.proxy_api_gw.id
  resource_id = aws_api_gateway_rest_api.proxy_api_gw.root_resource_id
  http_method = aws_api_gateway_method.root_proxy.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_resource" "greedy_proxy" {
  rest_api_id = aws_api_gateway_rest_api.proxy_api_gw.id
  parent_id   = aws_api_gateway_rest_api.proxy_api_gw.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "greedy_proxy" {
  rest_api_id      = aws_api_gateway_rest_api.proxy_api_gw.id
  resource_id      = aws_api_gateway_resource.greedy_proxy.id
  api_key_required = true
  http_method      = "ANY"
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "greedy_proxy" {
  rest_api_id = aws_api_gateway_rest_api.proxy_api_gw.id
  resource_id = aws_api_gateway_resource.greedy_proxy.id
  http_method = aws_api_gateway_method.greedy_proxy.http_method

  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

resource "aws_api_gateway_stage" "proxy_api_gw" {
  deployment_id = aws_api_gateway_deployment.proxy_api_gw.id
  rest_api_id   = aws_api_gateway_rest_api.proxy_api_gw.id
  stage_name    = var.api_deployment_stage_name
}

resource "aws_api_gateway_deployment" "proxy_api_gw" {
  rest_api_id = aws_api_gateway_rest_api.proxy_api_gw.id

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.root_proxy,
      aws_api_gateway_integration.root_proxy,
      aws_api_gateway_resource.greedy_proxy,
      aws_api_gateway_method.greedy_proxy,
      aws_api_gateway_integration.greedy_proxy,
    ]))
  }
}

resource "aws_api_gateway_usage_plan" "proxy_api_gw" {
  name        = "general-access"
  description = "General access to the API."

  api_stages {
    api_id = aws_api_gateway_rest_api.proxy_api_gw.id
    stage  = aws_api_gateway_stage.proxy_api_gw.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "proxy_api_gw" {
  key_id        = aws_api_gateway_api_key.proxy_api_gw.id
  usage_plan_id = aws_api_gateway_usage_plan.proxy_api_gw.id
  key_type      = "API_KEY"
}

resource "aws_api_gateway_api_key" "proxy_api_gw" {
  name  = "${var.resource_prefix}${var.api_gateway_name}-api-key"
  value = random_password.api_key.result
}

resource "random_password" "api_key" {
  length           = 128
  special          = false
  override_special = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
}
