output "cloudfront_domain" {
  description = "The domain of the application's CloudFront distribution."
  value       = module.cdn.domain_name
}
