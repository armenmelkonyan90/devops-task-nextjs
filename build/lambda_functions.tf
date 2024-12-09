resource "aws_iam_policy" "lambda_s3_policy" {
  name        = "${local.app_name}-lambda-s3-policy"
  description = "Policy for Lambda function to access S3 bucket"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowLambdaAccessToS3Bucket",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "${module.s3_bucket.bucket_arn}/*",
        "${module.s3_bucket.bucket_arn}"
      ]
    }
  ]
}
EOF
  tags        = local.additional_tags
}

resource "aws_iam_policy" "sqs_policy_agent" {
  name        = "${local.app_name}-sqs-policy"
  description = "Policy for access to SQS queue"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAccessToSQSQueue",
      "Effect": "Allow",
      "Action": [
        "sqs:SendMessage",
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": [
        "${aws_sqs_queue.revalidation.arn}"
      ]
    }
  ]
}
EOF
  tags        = local.additional_tags
}

module "server-functions" {
  source                         = "./modules/lambda_functions"
  trigger                        = "cloudfront"
  handler                        = "index.handler"
  function_name                  = "${local.app_name}-server-functions"
  lambda_zip                     = "server-functions.zip"
  runtime                        = "nodejs20.x"
  code_source_dir                = "../out/server-functions/default"
  source_arn                     = module.cloudfront.cloudfront_dist_arn
  lambda_insights_arn            = var.lambda_insights_arn
  reserved_concurrent_executions = local.reserved_concurrent_executions_per_lambda
  memory_size                    = var.lambda_memory_size
  policies                       = [aws_iam_policy.lambda_s3_policy.arn, aws_iam_policy.sqs_policy_agent.arn]
  tags                           = local.additional_tags
  env_variables = merge(local.lambda_env, {
    FUNCTION_NAME : "server-functions"
  })
}

module "image-optimization-function" {
  source                         = "./modules/lambda_functions"
  trigger                        = "cloudfront"
  handler                        = "index.handler"
  function_name                  = "${local.app_name}-image-optimization-function"
  lambda_zip                     = "image-optimization-function.zip"
  runtime                        = "nodejs20.x"
  code_source_dir                = "../out/image-optimization-function"
  source_arn                     = module.cloudfront.cloudfront_dist_arn
  lambda_insights_arn            = var.lambda_insights_arn
  reserved_concurrent_executions = local.reserved_concurrent_executions_per_lambda
  memory_size                    = var.lambda_memory_size
  policies                       = [aws_iam_policy.lambda_s3_policy.arn]
  tags                           = local.additional_tags
  env_variables = merge(local.lambda_env, {
    FUNCTION_NAME : "image-optimization-function"
  })
}

module "warmer_function" {
  source                         = "./modules/lambda_functions"
  trigger                        = "eventbridge"
  handler                        = "index.handler"
  function_name                  = "${local.app_name}-warmer_function"
  lambda_zip                     = "warmer_function.zip"
  runtime                        = "nodejs20.x"
  code_source_dir                = "../out/warmer-function"
  source_arn                     = aws_cloudwatch_event_rule.warmer_function_rule.arn
  lambda_insights_arn            = var.lambda_insights_arn
  reserved_concurrent_executions = local.reserved_concurrent_executions_per_lambda
  memory_size                    = var.lambda_memory_size
  policies                       = []
  tags                           = local.additional_tags
  env_variables = merge(local.lambda_env, {
    FUNCTION_NAME : "warmer_function"
  })
}

module "revalidation_function" {
  source                         = "./modules/lambda_functions"
  trigger                        = "sqs"
  handler                        = "index.handler"
  function_name                  = "${local.app_name}-revalidation_function"
  lambda_zip                     = "revalidation_function.zip"
  runtime                        = "nodejs20.x"
  code_source_dir                = "../out/revalidation-function"
  source_arn                     = aws_sqs_queue.revalidation.arn
  lambda_insights_arn            = var.lambda_insights_arn
  reserved_concurrent_executions = local.reserved_concurrent_executions_per_lambda
  memory_size                    = var.lambda_memory_size
  policies                       = [aws_iam_policy.sqs_policy_agent.arn, aws_iam_policy.lambda_s3_policy.arn]
  tags                           = local.additional_tags
  env_variables = merge(local.lambda_env, {
    FUNCTION_NAME : "revalidation_function"
  })
}




