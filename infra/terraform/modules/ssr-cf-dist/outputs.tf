output "id" {
  description = "The ID of the AWS CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.id
}

output "arn" {
  description = "The ARN of the AWS CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.arn
}

output "domain_name" {
  description = "The domain name corresponding to the AWS CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.domain_name
}

output "hosted_zone_id" {
  description = "The CloudFront Route 53 zone ID that can be used to route an alias resource record set to."
  value       = aws_cloudfront_distribution.cdn.hosted_zone_id
}

output "last_modified_time" {
  description = "Date/time that the distribution was last modified."
  value       = aws_cloudfront_distribution.cdn.last_modified_time
}
