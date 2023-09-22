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

variable "domain_name" {
  default     = ""
  type        = string
  description = "The domain name to point to the application. Required if a hosted zone ID is provided. This must be manually registered."
}

variable "route53_hosted_zone_id" {
  default     = ""
  type        = string
  description = "The Route 53 hosted zone ID to use to point to the application. Required if a domain name is provided. This must be manually provisioned."
}

variable "subdomain" {
  default     = ""
  type        = string
  description = "An optional subdomain to use. If provided, a CNAME record will automatically be created for it."
}

variable "acm_certificate_arn" {
  default     = ""
  description = "The ARN of an AWS ACM certificate to use for the CloudFront domain, if using a custom domain. It must be in us-west-1. If not provided, a new certificate will be provisioned."
  type        = string
}

variable "route53_domain_cross_account_assume_role_configuration" {
  default     = null
  description = "Configuration for assuming a role in another AWS account, if your Route53 hosted zone sits in a different account. The IAM role used to run Terraform must have permission to assume this role."
  type = object({
    role_arn     = string
    session_name = string
    external_id  = string
  })
}
