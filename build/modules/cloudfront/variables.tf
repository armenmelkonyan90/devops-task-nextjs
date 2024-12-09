variable "app_name" {
  description = "The name of app. "
  type        = string
  default     = ""
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
}

variable "cloudfront_enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content."
  type        = bool
  default     = true
}

variable "is_ipv6_enabled" {
  description = "Whether the IPv6 is enabled for the distribution."
  type        = bool
  default     = true
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

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources."
  default     = {}
}

variable "origins" {
  description = "List of origins for CloudFront distribution"
  type = list(object({
    id          = string           # Unique identifier for the origin
    domain      = string           # Domain name of the origin
    type        = string           # Origin type: 's3' or 'custom'
    origin_path = optional(string) # Optional path prefix for the origin
  }))
  default = []
}

variable "ordered_cache_behavior" {
  description = "List of ordered cache behaviors for the CloudFront distribution."
  type = list(object({
    path_pattern     = string       # Path pattern to match (e.g., "/images/*").
    allowed_methods  = list(string) # Allowed HTTP methods (e.g., ["GET", "HEAD", "OPTIONS"]).
    cached_methods   = list(string) # Cached HTTP methods (e.g., ["GET", "HEAD"]).
    target_origin_id = string       # ID of the target origin for this behavior.
  }))
  default = []
}

variable "viewer_certificate" {
  description = "The SSL configuration for this distribution"
  type        = any
  default = {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }
}

variable "geo_restriction_type" {
  description = "Method that you want to use to restrict distribution of your content by country"
  type        = string
  default     = "none"
}

variable "locations" {
  description = "Locations for which you want CloudFront either to distribute your content"
  type        = list(string)
  default     = []
}

variable "default_origin_id" {
  description = "Cloudfront distribution origin identifier."
  type        = string
  default     = ""
}

variable "logs_bucket" {
  description = "The Amazon S3 bucket to store the access logs in, for example, myawslogbucket.s3.amazonaws.com"
  type        = string
  default     = ""
}
