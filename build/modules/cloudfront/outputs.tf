output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "cloudfront_dist_id" {
  value = aws_cloudfront_distribution.this.id
}

output "cloudfront_dist_arn" {
  value = aws_cloudfront_distribution.this.arn
}

output "hosted_zone_id" {
  value       = aws_cloudfront_distribution.this.hosted_zone_id
  description = "The hosted zone id for cloudfront aliases."
}
output "aws_cloudfront_origin_access_identity" {
  value = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
}

