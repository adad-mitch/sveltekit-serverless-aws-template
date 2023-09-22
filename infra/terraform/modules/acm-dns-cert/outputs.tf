output "arn" {
  description = "The ARN of the ACM certificate."
  value       = aws_acm_certificate.cert.arn
}

output "not_before" {
  description = "Start of the validity period of the AWS ACM certificate."
  value       = aws_acm_certificate.cert.not_before
}

output "not_after" {
  description = "Expiration date and time of the AWS ACM certificate."
  value       = aws_acm_certificate.cert.not_after
}
