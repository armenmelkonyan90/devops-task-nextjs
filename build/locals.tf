locals {
  app_name                           = "${var.env}-${var.app_name}"
  reserved_concurrent_execution_pool = 1000
  # Maximum of 1000 reserved concurrent executions across all lambdas. https://docs.aws.amazon.com/lambda/latest/dg/configuration-concurrency.html
  reserved_concurrent_executions_per_lambda = local.reserved_concurrent_execution_pool / 20
  mime_types                                = jsondecode(file("./mime.json"))
  # s3_build_folder                           = "../out/assets"
  lambda_env = {
    NODE_ENV = "development"
  }
  required_tags = {
    Application = "devops-task"
  }
  additional_tags = {
    ENV = "dev"
  }
  origins = [{
    id          = "${var.env}-assets-s3"
    domain      = module.s3_bucket.regional_domain_name
    type        = "s3"
    origin_path = "/assets"
    },
    {
      id          = "${var.env}-server-function"
      domain      = "${module.server-functions.lambda_function_url_id}.lambda-url.${var.provider_region}.on.aws" #replace(module.server-functions.lambda_function_url, "https://", "") # Strip https:// "${module.server-functions.lambda_function_url}"
      type        = "custom"
      origin_path = null
    },
    {
      id          = "${var.env}-image-optimization-function"
      domain      = "${module.image-optimization-function.lambda_function_url_id}.lambda-url.${var.provider_region}.on.aws" # replace(module.image-optimization-function.lambda_function_url, "https://", "") #"${module.image-optimization-function.lambda_function_url}"
      type        = "custom"
      origin_path = null
    }
  ]
  ordered_cache_behavior = [
    {
      path_pattern     = "/_next/static/*"
      allowed_methods  = ["GET", "HEAD", "OPTIONS"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "${var.env}-assets-s3"
    },
    {
      path_pattern     = "/api/*"
      allowed_methods  = ["GET", "HEAD", "OPTIONS"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = "${var.env}-server-function"
    },
    

  ]
  viewer_certificate = {
    acm_certificate_arn            = var.create_records ? aws_acm_certificate.cloudfront[0].arn : null
    cloudfront_default_certificate = !var.create_records
    ssl_support_method             = var.create_records ? "sni-only" : null
    minimum_protocol_version       = var.create_records ? "TLSv1.2_2021" : "TLSv1"
  }
}
