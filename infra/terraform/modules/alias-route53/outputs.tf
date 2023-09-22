output "fqdn" {
  description = "The FQDN of the Route53 record without a leading 'www'. This will point to the 'www' subdomain in the `www_fqdn` output."
  value       = aws_route53_record.www_redirect.fqdn
}

output "www_fqdn" {
  description = "The FQDN of the Route53 record prefixed with a 'www'. This will point to the specified alias."
  value       = aws_route53_record.www_to_alias.fqdn
}
