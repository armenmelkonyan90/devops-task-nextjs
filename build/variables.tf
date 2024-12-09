variable "provider_region" {
  description = "AWS region where this infrastructure is going to be deployed"
  type        = string
  default     = "us-west-2"
}

variable "app_name" {
  description = "The name of app. "
  type        = string
  default     = "devops-task"
}

variable "env" {
  description = "Application environment name"
  type        = string
  default     = "dev"
}

variable "lambda_insights_arn" {
  description = "ARN of the Lambda Insights extension to install. Reference: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versions.html"
  type        = list(string)
  default     = [""]
}

variable "lambda_memory_size" {
  type        = string
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  default     = "128"
}

variable "cache_policy" {
  description = "Configuration for CloudFront cache policy, including TTL settings, compression preferences, cookies, headers, and query strings."
  type = object({
    default_ttl                   = number,
    max_ttl                       = number,
    min_ttl                       = number
    enable_accept_encoding_gzip   = bool
    enable_accept_encoding_brotli = bool
    cookie_behavior               = string # Options: none, whitelist, all
    cookie_behavior_items         = list(string)
    header_behavior               = string # Options: none, whitelist, all
    header_behavior_items         = list(string)
    query_string_behavior         = string # Options: none, whitelist, all
    query_string_behavior_items   = list(string)
  })
  default = {
    default_ttl                   = 50
    max_ttl                       = 100
    min_ttl                       = 1
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true
    cookie_behavior               = "none"
    cookie_behavior_items         = []
    header_behavior               = "whitelist"
    header_behavior_items         = ["accept", "rsc", "next-router-prefetch", "next-router-state-tree", "x-prerender-revalidate"]
    query_string_behavior         = "none"
    query_string_behavior_items   = []
  }
}

variable "origin_request_policies" {
  description = "Defines behavior for cookies, headers, and query strings in the origin request policy."
  type = object({
    cookie_behavior             = string,
    cookie_behavior_items       = list(string),
    header_behavior             = string,
    header_behavior_items       = list(string),
    query_string_behavior       = string,
    query_string_behavior_items = list(string)
  })
  default = {
    cookie_behavior             = "none"
    cookie_behavior_items       = []
    header_behavior             = "whitelist"
    header_behavior_items       = ["accept", "rsc", "next-router-prefetch", "next-router-state-tree", "x-prerender-revalidate"]
    query_string_behavior       = "none"
    query_string_behavior_items = []
  }
}

variable "response_headers_policy" {
  description = "Configuration for the CloudFront response headers policy"
  type = object({
    access_control_max_age_sec   = number
    include_subdomains           = bool
    override                     = bool
    preload                      = bool
    cors_origin_override         = bool
    cors_allow_credentials       = bool
    access_control_allow_headers = list(string)
    access_control_allow_methods = list(string)
    access_control_allow_origins = list(string)
  })
  default = {
    access_control_max_age_sec   = 31536000
    include_subdomains           = true
    override                     = true
    preload                      = true
    cors_origin_override         = true
    cors_allow_credentials       = true
    access_control_allow_headers = ["Content-Type", "Authorization"]
    access_control_allow_methods = ["GET", "POST", "OPTIONS"]
    access_control_allow_origins = ["https://example.com"]
  }
}

variable "cname_domain" {
  type        = list(any)
  description = "The domain name for this distribution."
  default     = null
}

variable "price_class" {
  description = "Price class for this distribution. One of PriceClass_All, PriceClass_200, PriceClass_100."
  type        = string
  default     = "PriceClass_All"
}

variable "origins" {
  description = "List of origins for CloudFront distribution"
  type = list(object({
    id          = string           # Unique identifier for the origin
    domain      = string           # Domain name of the origin
    type        = string           # Origin type: 's3' or 'custom'
    origin_path = optional(string) # Optional path prefix for the origin
  }))
  default = [
    #   {
    #     id          = "assets-origin"
    #     domain      = "assets-bucket.s3.amazonaws.com"
    #     type        = "s3"
    #     origin_path = null
    #   },
    #   {
    #     id          = "server-origin"
    #     domain      = "api.example.com"
    #     type        = "custom"
    #     origin_path = "/api"
    #   },
    #   {
    #     id          = "image-optimization-origin"
    #     domain      = "image-optimization.example.com"
    #     type        = "custom"
    #     origin_path = null
    #   }
  ]
}

variable "ordered_cache_behavior" {
  description = "List of ordered cache behaviors for the CloudFront distribution."
  type = list(object({
    path_pattern               = string       # Path pattern to match (e.g., "/images/*").
    allowed_methods            = list(string) # Allowed HTTP methods (e.g., ["GET", "HEAD", "OPTIONS"]).
    cached_methods             = list(string) # Cached HTTP methods (e.g., ["GET", "HEAD"]).
    target_origin_id           = string       # ID of the target origin for this behavior.
    origin_request_policy_name = string       # Name of the origin request policy.
  }))
  default = [
    {
      path_pattern               = "*"
      allowed_methods            = ["GET", "HEAD", "OPTIONS"]
      cached_methods             = ["GET", "HEAD"]
      target_origin_id           = "default-origin"
      origin_request_policy_name = "default-origin-request-policy"
    }
  ]
}

variable "hashed_files_config" {
  description = "The recommended cache control setting for hashed files"
  type        = string
  default     = "public,max-age=31536000,immutable"
}

variable "unhashed_files_config" {
  description = "The recommended cache control setting for unhashed files"
  type        = string
  default     = "public,max-age=0,s-maxage=31536000,must-revalidate"
}

variable "create_records" {
  description = "Create record cloudfront"
  type        = bool
  default     = false
}

variable "route53_domain_name" {
  description = "Route_53 domain name"
  type        = string
  default     = ""
}

variable "route53_zoneid" {
  description = "Route_53 zone id"
  type        = string
  default     = ""
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "The duration (in seconds) that a received message is hidden from subsequent retrieve requests after being received."
  default     = 60

}

variable "max_message_size" {
  type        = number
  description = "The maximum message size in bytes for the SQS queue. The default (and maximum) is 262144 bytes (256 KB)."
  default     = 262144
}

variable "fifo_queue" {
  description = "Is sqs queue is fifo"
  type        = bool
  default     = true
}
