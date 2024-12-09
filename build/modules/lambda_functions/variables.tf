variable "function_name" {
  type        = string
  description = "The name of the function."
}

variable "code_source_dir" {
  type        = string
  description = "The location of the source files."
}

variable "lambda_zip" {
  description = "The zip file name for uploading as lambda function"
  type        = string
}

variable "runtime" {
  type        = string
  description = "Identifier of the function's runtime."

}

variable "logs_retention_in_days" {
  type        = number
  description = "The number of days to retain logs."
  default     = 90
}

variable "env_variables" {
  type        = map(any)
  description = "Environment variables for the lambda."
  default     = {}
}

variable "tags" {
  type        = map(any)
  description = "Tags to apply to resources."
  default     = {}
}

variable "policies" {
  type        = list(any)
  description = "Policies to be attached to the Lambda"
  default     = []
}

variable "source_arn" {
  type        = string
  description = "ARN of the AWS resource permitted to invoke the function"
  default     = ""
}

variable "lambda_insights_arn" {
  description = "ARN of the Lambda Insights extension to install. Reference: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Lambda-Insights-extension-versions.html"
  type        = list(string)
  default     = [""]
}

variable "reserved_concurrent_executions" {
  description = "Amount of reserved concurrent executions for this lambda function."
  type        = number
  default     = -1
}

variable "timeout" {
  type        = number
  description = "Number of seconds the lambda function has to run before timing out."
  default     = 60
}

variable "lambda_subnet_ids" {
  type        = list(any)
  description = "VPC subnet id for lambda function. "
  default     = []
}

variable "security_group_ids" {
  type        = list(any)
  description = "VPC security group id for lambda function. "
  default     = []
}

variable "trigger" {
  type        = string
  description = "Trigger type for lambda function execution. "
  validation {
    condition     = var.trigger == "cloudfront" || var.trigger == "eventbridge" || var.trigger == "sqs"
    error_message = "Invalid trigger type. Allowed values are: cloudfront, eventbridge, or sqs."
  }
  default = "cloudfront"
}

variable "handler" {
  type        = string
  description = "The lambda function handler name."
}

variable "memory_size" {
  type        = string
  description = "Amount of memory in MB your Lambda Function can use at runtime"
  default     = "128"
}

variable "batch_size" {
  type        = number
  description = "number of messages the Lambda function retrieves in a single batch"
  default     = 10
}

variable "maximum_concurrency" {
  type        = number
  description = "Limits the number of concurrent instances that the Amazon SQS event source can invoke."
  default     = 2

}

variable "cors" {
  description = "The cross-origin resource sharing (CORS) settings for the function URL."
  type        = any
  default     = {}
}
