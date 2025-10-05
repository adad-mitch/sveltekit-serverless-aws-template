resource "aws_lambda_permission" "api_gw_invocation" {
  statement_id  = "AllowInvocationFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_stage.proxy_api_gw.execution_arn}*"
}


resource "aws_iam_role" "lambda_role" {
  name = "${var.resource_prefix}${var.lambda_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAssumeRoleAsLambda"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "simple_logging_policy" {
  name        = "${var.resource_prefix}simple-logging-policy"
  description = "Provides simple log group/stream read/write permissions."

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "AllowSimpleLogging",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_can_log" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.simple_logging_policy.arn
}
