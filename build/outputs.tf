output "cloudfront_DNS_name" {
  description = "CloudFront destribution DNS name"
  value       = module.cloudfront.cloudfront_domain_name
}

output "lambda_function_url" {
  value = module.server-functions.lambda_function_url_id

}
