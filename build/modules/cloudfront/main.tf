resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin access identity for s3 bucket."
}

resource "aws_cloudfront_cache_policy" "cache_policy" {
  name        = "${var.app_name}-cache-policy"
  default_ttl = var.cache_policy.default_ttl
  max_ttl     = var.cache_policy.max_ttl
  min_ttl     = var.cache_policy.min_ttl

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = var.cache_policy.enable_accept_encoding_gzip
    enable_accept_encoding_brotli = var.cache_policy.enable_accept_encoding_brotli

    cookies_config {
      cookie_behavior = var.cache_policy.cookie_behavior
      cookies {
        items = var.cache_policy.cookie_behavior_items
      }
    }
    headers_config {
      header_behavior = var.cache_policy.header_behavior
      headers {
        items = var.cache_policy.header_behavior_items
      }
    }
    query_strings_config {
      query_string_behavior = var.cache_policy.query_string_behavior
      query_strings {
        items = var.cache_policy.query_string_behavior_items
      }
    }
  }
}

resource "aws_cloudfront_origin_request_policy" "request_policy" {
  name = "${var.app_name}-origin-request-policy"
  cookies_config {
    cookie_behavior = var.origin_request_policies.cookie_behavior
    cookies {
      items = var.origin_request_policies.cookie_behavior_items
    }
  }
  headers_config {
    header_behavior = var.origin_request_policies.header_behavior
    headers {
      items = var.origin_request_policies.header_behavior_items
    }
  }
  query_strings_config {
    query_string_behavior = var.origin_request_policies.query_string_behavior
    query_strings {
      items = var.origin_request_policies.query_string_behavior_items
    }
  }
}

resource "aws_cloudfront_response_headers_policy" "strict_transport_security" {
  name = "${var.app_name}-strict-transport-security-policy"

  security_headers_config {
    strict_transport_security {
      access_control_max_age_sec = var.response_headers_policy.access_control_max_age_sec
      include_subdomains         = var.response_headers_policy.include_subdomains
      override                   = var.response_headers_policy.override
      preload                    = var.response_headers_policy.preload
    }
  }

  cors_config {
    origin_override                  = var.response_headers_policy.cors_origin_override
    access_control_allow_credentials = var.response_headers_policy.cors_allow_credentials

    access_control_allow_headers {
      items = var.response_headers_policy.access_control_allow_headers
    }

    access_control_allow_methods {
      items = var.response_headers_policy.access_control_allow_methods
    }

    access_control_allow_origins {
      items = var.response_headers_policy.access_control_allow_origins
    }
  }
}

resource "aws_cloudfront_distribution" "this" {
  enabled         = var.cloudfront_enabled
  is_ipv6_enabled = var.is_ipv6_enabled
  aliases         = var.cname_domain
  price_class     = var.price_class
  tags            = var.tags
  dynamic "origin" {
    for_each = var.origins
    content {
      domain_name = origin.value.domain
      origin_id   = origin.value.id
      origin_path = try(origin.value.origin_path)

      dynamic "s3_origin_config" {
        for_each = origin.value.type == "s3" ? [true] : []
        content {
          origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
        }
      }

      dynamic "custom_origin_config" {
        for_each = origin.value.type == "custom" ? [true] : []
        content {
          http_port              = 80
          https_port             = 443
          origin_protocol_policy = "https-only"
          origin_ssl_protocols   = ["TLSv1.2"]
        }
      }
    }
  }

  dynamic "ordered_cache_behavior" {
    for_each = var.ordered_cache_behavior

    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = ordered_cache_behavior.value.allowed_methods
      cached_methods   = ordered_cache_behavior.value.cached_methods
      target_origin_id = ordered_cache_behavior.value.target_origin_id

      response_headers_policy_id = aws_cloudfront_response_headers_policy.strict_transport_security.id
      cache_policy_id            = aws_cloudfront_cache_policy.cache_policy.id
      origin_request_policy_id   = aws_cloudfront_origin_request_policy.request_policy.id


      compress               = true
      viewer_protocol_policy = "redirect-to-https"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = lookup(var.viewer_certificate, "acm_certificate_arn", null)
    cloudfront_default_certificate = lookup(var.viewer_certificate, "cloudfront_default_certificate", null)
    ssl_support_method             = lookup(var.viewer_certificate, "ssl_support_method", null)
    minimum_protocol_version       = lookup(var.viewer_certificate, "minimum_protocol_version", null)
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.locations
    }
  }

  default_cache_behavior {
    allowed_methods            = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    target_origin_id           = var.default_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    cache_policy_id            = aws_cloudfront_cache_policy.cache_policy.id
    origin_request_policy_id   = aws_cloudfront_origin_request_policy.request_policy.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.strict_transport_security.id
  }

dynamic "logging_config" {
  for_each = var.logs_bucket != "" ? [var.logs_bucket] : []

  content {
    include_cookies = false
    bucket          = logging_config.value
    prefix          = var.app_name
  }
}
}


