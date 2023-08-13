resource "aws_api_gateway_rest_api" "proxy_api_gw" {
  name        = "${var.resource_prefix}${var.api_gateway_name}"
  description = var.api_gateway_description
}

resource "aws_api_gateway_method" "root_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.proxy_api_gw.id
  resource_id   = aws_api_gateway_rest_api.proxy_api_gw.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
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
  rest_api_id   = aws_api_gateway_rest_api.proxy_api_gw.id
  resource_id   = aws_api_gateway_resource.greedy_proxy.id
  http_method   = "ANY"
  authorization = "NONE"
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
