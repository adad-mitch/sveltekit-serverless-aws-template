variable "aws_profile" {
  default     = "default"
  description = "The AWS profile to use to provision resources. Uses the default profile if unset."
  type        = string
}

variable "aws_region" {
  default     = "us-west-1"
  description = "The AWS region to deploy resources to. Defaults to us-west-1 (N. Virginia)."
  type        = string
}

variable "aws_resource_prefix" {
  default     = ""
  description = "A prefix to be appended to the start of resources provisioned in AWS, where applicable."
  type        = string
}

variable "build_artefact_path" {
  description = "The absolute path of the build artefact to be deployed to AWS Lambda."
  type        = string
}

variable "deployment_lambda_handler_name" {
  default     = "lambda.handler"
  description = "The name of the deployment target AWS Lambda function handler (i.e., {filename}.{entrypoint function/method})."
  type        = string
}

variable "deployment_lambda_handler_runtime" {
  default     = "nodejs18.x"
  description = "The runtime of the deployment target AWS Lambda function (e.g., nodejsXX.x)."
  type        = string
}
