variable "aws_profile" {
  default     = "default"
  description = "The AWS profile to use for AWS CLI commands. This should match the one used in the 'providers' block of the calling module."
  type        = string
}

variable "resource_prefix" {
  default     = ""
  description = "A value to prefix provisioned resources with, where applicable."
  type        = string

  validation {
    condition     = var.resource_prefix == "" || substr(var.resource_prefix, -1, 1) == "-"
    error_message = "If a resource prefix is provided, it must end with a hyphen (-)."
  }
}

variable "lambda_name" {
  description = "The name to give to the AWS Lambda function."
  type        = string
}

variable "lambda_handler_name" {
  description = "The name of the AWS Lambda function handler (i.e., {filename}.{entrypoint function/method})."
  type        = string
}

variable "lambda_handler_runtime" {
  description = "The type of runtime to use for the AWS Lambda function (e.g., nodejsXX.x)."
  type        = string
}

variable "lambda_source_path" {
  description = "The absolute path of the source to use for the AWS Lambda function."
  type        = string

  validation {
    condition     = substr(var.lambda_source_path, -1, 1) == "/"
    error_message = "The source path must have a trailing slash (/)."
  }
}

variable "api_gateway_name" {
  description = "The name to give to the AWS API Gateway."
  type        = string
}

variable "api_gateway_description" {
  default     = ""
  description = "The description to give to the AWS API Gateway."
  type        = string
}

variable "api_deployment_stage_name" {
  default     = "prod"
  description = "The name to give to the AWS API Gateway stage to deploy to."
  type        = string
}
