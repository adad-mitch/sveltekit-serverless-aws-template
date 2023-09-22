resource "aws_acm_certificate" "cert" {
  provider = aws.acm

  domain_name               = "${var.subdomain}${var.domain_name}"
  subject_alternative_names = ["*.${var.subdomain}${var.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}
