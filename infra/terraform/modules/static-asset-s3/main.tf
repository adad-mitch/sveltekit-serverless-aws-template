resource "aws_s3_bucket" "bucket" {
  bucket = "${var.resource_prefix}${var.bucket_name}-${random_integer.bucket.id}"
}

resource "random_integer" "bucket" {
  min = 1
  max = 65535
}

resource "aws_s3_bucket_policy" "bucket" {
  count = length(var.cf_dist_arns)

  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : {
      "Sid" : "AllowCloudFrontServicePrincipalReadOnly",
      "Effect" : "Allow",
      "Principal" : {
        "Service" : "cloudfront.amazonaws.com"
      },
      "Action" : "s3:GetObject",
      "Resource" : "${aws_s3_bucket.bucket.arn}/*",
      "Condition" : {
        "StringEquals" : {
          "AWS:SourceArn" : var.cf_dist_arns
        }
      }
    }
  })
}

resource "aws_s3_object" "assets" {
  for_each = fileset(var.static_assets_source_path, "**")

  bucket = aws_s3_bucket.bucket.id
  key    = each.value
  source = "${var.static_assets_source_path}${each.value}"
  etag   = filemd5("${var.static_assets_source_path}${each.value}")

  # Gets the file extension (i.e., the string after the last ".") and finds its respective MIME type from a map of content types.
  # Not the most pulchritudinous; prettier approaches are welcome.
  content_type = lookup(local.content_type_map, element(split(".", each.value), length(split(".", each.value)) - 1), "binary/octet-stream")
}
