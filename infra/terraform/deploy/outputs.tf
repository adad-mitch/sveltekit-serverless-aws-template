output "front_domain" {
  description = "The domain of the application (either the generated AWS CloudFront Distribution URL or a domain you specified successfully)."
  value       = try(module.routing[0], null) != null ? module.routing[0].www_fqdn : module.cdn.domain_name
}
