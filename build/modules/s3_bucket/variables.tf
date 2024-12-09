variable "app_name" {
  description = "The name of app. "
  type        = string
  default     = ""
}

variable "force_destroy" {
  description = "A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. "
  type        = bool
  default     = false
}

variable "object_lock_enabled" {
  description = "Specifies whether object locking configuration is enabled for this container."
  type        = bool
  default     = false
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources."
  default     = {}
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should block public ACLs for this bucket."
  type        = bool
  default     = true
}

variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket. "
  type        = bool
  default     = true
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type        = bool
  default     = true
}

variable "source_policy_documents" {
  description = "List of IAM policy documents"
  type        = string
  default     = ""
}
