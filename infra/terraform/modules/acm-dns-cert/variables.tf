variable "resource_prefix" {
  default     = ""
  description = "A value to prefix provisioned resources with, where applicable."
  type        = string

  validation {
    condition     = var.resource_prefix == "" || substr(var.resource_prefix, -1, 1) == "-"
    error_message = "If a resource prefix is provided, it must end with a hyphen (-)."
  }
}

variable "domain_name" {
  description = "The domain name that the certificate should be issued for. This certificate will be issued against this and a wildcard domain (i.e., *.{domain_name}), to allow for DNS validation and for subdomains to be used."
  type        = string
}

variable "subdomain" {
  default     = ""
  description = "An optional subdomain to use. An additional SAN will be added for this."
  type        = string

  validation {
    condition     = var.subdomain == "" || substr(var.subdomain, -1, 1) == "."
    error_message = "If a subdomain is provided, it must end with a period (.)."
  }
}

variable "hosted_zone_id" {
  description = "The ID of the AWS Route53 hosted zone to perform DNS validation of the provisioned AWS ACM certificate against. This must be manually provisioned."
  type        = string
}
