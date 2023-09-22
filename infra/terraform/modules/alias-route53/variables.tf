variable "resource_prefix" {
  default     = ""
  description = "A value to prefix provisioned resources with, where applicable."
  type        = string

  validation {
    condition     = var.resource_prefix == "" || substr(var.resource_prefix, -1, 1) == "-"
    error_message = "If a resource prefix is provided, it must end with a hyphen (-)."
  }
}

variable "hosted_zone_id" {
  description = "The ID of the AWS Route53 hosted zone to create records in. This must be manually provisioned."
  type        = string
}

variable "domain_name" {
  description = "The domain name to create records for. This must be manually registered."
  type        = string
}

variable "subdomain" {
  default     = ""
  description = "An optional subdomain to use. If provided, a CNAME record will automatically be created for it."
  type        = string

  validation {
    condition     = var.subdomain == "" || substr(var.subdomain, -1, 1) == "."
    error_message = "If a subdomain is provided, it must end with a period (.)."
  }
}

variable "alias_configuration" {
  description = "Configuration for the alias record to create. See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record#alias."
  type = object({
    name                   = string
    zone_id                = string
    evaluate_target_health = bool
  })
}
