# "www" subdomain points directly to CloudFront.
resource "aws_route53_record" "www_to_alias" {
  name    = "www.${var.subdomain}${var.domain_name}"
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = var.alias_configuration.name
    zone_id                = var.alias_configuration.zone_id
    evaluate_target_health = var.alias_configuration.evaluate_target_health
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Redirects to the "www" subdomain for cookie isolation.
resource "aws_route53_record" "www_redirect" {
  name    = "${var.subdomain}${var.domain_name}"
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = aws_route53_record.www_to_alias.name
    zone_id                = aws_route53_record.www_to_alias.zone_id
    evaluate_target_health = false
  }

  lifecycle {
    create_before_destroy = true
  }
}
