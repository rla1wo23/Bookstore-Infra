output "bucket_name" {
  value = aws_s3_bucket.frontend_bucket.id
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.frontend_distribution.domain_name
}
