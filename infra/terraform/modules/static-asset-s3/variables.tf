variable "resource_prefix" {
  default     = ""
  description = "A value to prefix provisioned resources with, where applicable."
  type        = string

  validation {
    condition     = var.resource_prefix == "" || substr(var.resource_prefix, -1, 1) == "-"
    error_message = "If a resource prefix is provided, it must end with a hyphen (-)."
  }
}

variable "bucket_name" {
  description = "The name to give to the AWS S3 bucket."
  type        = string
}

variable "static_assets_source_path" {
  description = "The absolute path of the source folder containing static assets to be placed in the AWS S3 bucket."
  type        = string

  validation {
    condition     = substr(var.static_assets_source_path, -1, 1) == "/"
    error_message = "The source path must have a trailing slash (/)."
  }
}

variable "cf_dist_arns" {
  default     = []
  description = "The CloudFront distribution ARN(s) to grant read access to the AWS S3 bucket."
  type        = list(string)
}
