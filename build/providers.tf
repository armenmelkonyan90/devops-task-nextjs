provider "aws" {
  region = var.provider_region

  default_tags {
    tags = local.required_tags
  }

}

provider "aws" {
  alias  = "acm"
  region = "us-east-1"

  default_tags {
    tags = local.required_tags
  }

}