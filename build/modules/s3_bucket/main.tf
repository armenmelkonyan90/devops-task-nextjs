resource "aws_s3_bucket" "this" {
  bucket              = "${var.app_name}-s3-bucket"
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags                = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = var.source_policy_documents
}

