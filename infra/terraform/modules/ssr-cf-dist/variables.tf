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

variable "s3_bucket_id" {
  description = "The ID (name) of the AWS S3 bucket origin."
  type        = string
}

variable "s3_bucket_regional_domain_name" {
  description = "The regional domain name of the AWS S3 bucket origin."
  type        = string
}

variable "api_gw_domain_name" {
  description = "The domain name (i.e., without the protocol or stage name) of the AWS API Gateway origin."
  type        = string
}

variable "api_gw_deployment_stage_name" {
  description = "The name of the deployment stage used by the AWS API Gateway origin."
  type        = string

  validation {
    condition     = substr(var.api_gw_deployment_stage_name, 0, 1) == "/"
    error_message = "The deployment stage name must start with a forward slash (/)."
  }
}

variable "api_gw_api_key" {
  description = "The API key to use for the AWS API Gateway origin. It will be forwarded as an `x-api-key` header."
  type        = string
  sensitive   = true
}

variable "acm_certificate_arn" {
  default     = ""
  description = "The ARN of an ACM certificate to use for the CloudFront domain. It must be in us-west-1. Required if you want to use a custom domain name (otherwise CloudFront will return a 403)."
  type        = string
}

variable "alternate_cnames" {
  default     = []
  description = "A set of alternate CNAMEs that the CloudFront distribution should be accessible from. The AWS ACM certificate provided should cover these domains."
  type        = set(string)
}
