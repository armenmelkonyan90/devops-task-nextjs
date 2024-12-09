

module "s3_bucket" {
  source                  = "./modules/s3_bucket"
  app_name                = local.app_name
  source_policy_documents = data.aws_iam_policy_document.s3_policy.json
  tags                    = local.additional_tags

}

module "cloudfront" {
  source                  = "./modules/cloudfront"
  app_name                = local.app_name
  cname_domain            = var.create_records ? [var.route53_domain_name] : null
  cache_policy            = var.cache_policy
  origin_request_policies = var.origin_request_policies
  response_headers_policy = var.response_headers_policy
  ordered_cache_behavior  = local.ordered_cache_behavior
  viewer_certificate      = local.viewer_certificate
  origins                 = local.origins
  default_origin_id       = "${var.env}-server-function"
  tags                    = local.additional_tags

}

data "aws_iam_policy_document" "s3_policy" {
  version = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject*", "s3:ListBucket"]
    resources = [
      "${module.s3_bucket.bucket_arn}",
      "${module.s3_bucket.bucket_arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["${module.cloudfront.aws_cloudfront_origin_access_identity}"]
    }
  }
}

resource "aws_s3_object" "assets" {
  bucket        = module.s3_bucket.bucket_id
  for_each      = fileset("../out/assets", "**")
  key           = "assets/${each.value}"
  source        = "../out/assets/${each.value}"
  content_type  = lookup(local.mime_types, try(regex("\\.[^.]+$", each.value), "default"), "text/plain")
  cache_control = length(regexall(".*(_next).*$", each.value)) > 0 ? var.hashed_files_config : var.unhashed_files_config
  etag          = "../out/assets/${each.value}"
}

resource "aws_s3_object" "cache" {
  bucket       = module.s3_bucket.bucket_id
  for_each     = fileset("../out/cache", "**")
  key          = "cache/${each.value}"
  source       = "../out/cache/${each.value}"
  content_type = lookup(local.mime_types, regex("\\.[^.]+$", each.value), "text/plain")
  etag         = "../out/cache/${each.value}"
}

resource "aws_sqs_queue" "revalidation" {
  name                       = "${local.app_name}-revalidation-turn.fifo"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  max_message_size           = var.max_message_size
  fifo_queue                 = var.fifo_queue
  tags                       = local.additional_tags
}

resource "aws_acm_certificate" "cloudfront" {
  count             = var.create_records ? 1 : 0
  provider          = aws.acm
  domain_name       = var.route53_domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
  tags = local.additional_tags
}

resource "aws_route53_record" "certificate_cname" {
  for_each = {
    for dvo in var.create_records ? aws_acm_certificate.cloudfront[0].domain_validation_options : [] :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zoneid
}

resource "aws_acm_certificate_validation" "cloudfront_cert_validation" {
  count                   = var.create_records ? 1 : 0
  provider                = aws.acm
  certificate_arn         = aws_acm_certificate.cloudfront[0].arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_cname : record.fqdn]
}
