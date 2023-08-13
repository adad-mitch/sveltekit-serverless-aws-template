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
