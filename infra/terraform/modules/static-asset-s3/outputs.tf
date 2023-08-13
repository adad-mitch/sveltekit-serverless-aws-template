output "id" {
  description = "The name of the AWS S3 bucket."
  value       = aws_s3_bucket.bucket.id
}

output "arn" {
  description = "The ARN of the AWS S3 bucket."
  value       = aws_s3_bucket.bucket.arn
}

output "bucket_domain_name" {
  description = "The domain name of the S3 bucket."
  value       = aws_s3_bucket.bucket.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The region-specific domain name of the S3 bucket. This is useful when behind a CloudFront distribution."
  value       = aws_s3_bucket.bucket.bucket_regional_domain_name
}
