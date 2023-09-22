resource "aws_route53_record" "dns_validation" {
  provider = aws.route53

  zone_id = var.hosted_zone_id
  name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  records = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  ttl     = 300

  lifecycle {
    create_before_destroy = true
  }
}
