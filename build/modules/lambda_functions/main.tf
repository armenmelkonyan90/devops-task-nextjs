resource "aws_iam_role" "iam_for_lambda" {
  name               = "${var.function_name}-role"
  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "lambda.amazonaws.com"
          },
          "Effect": "Allow",
          "Sid": ""
        }
      ]
    }
  EOF

  tags = var.tags

}

resource "aws_iam_role_policy_attachment" "basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}


resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.iam_for_lambda.name
}

resource "aws_iam_role_policy_attachment" "insights" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "additional" {
  count      = length(var.policies)
  policy_arn = var.policies[count.index]
  role       = aws_iam_role.iam_for_lambda.name
}

data "archive_file" "lambda_files" {
  type        = "zip"
  source_dir  = var.code_source_dir
  output_path = var.lambda_zip
}


resource "aws_lambda_function" "lambda" {
  function_name                  = var.function_name
  filename                       = var.lambda_zip
  role                           = aws_iam_role.iam_for_lambda.arn
  handler                        = var.handler
  source_code_hash               = data.archive_file.lambda_files.output_base64sha256
  runtime                        = var.runtime
  timeout                        = var.timeout
  memory_size                    = var.memory_size
  reserved_concurrent_executions = var.reserved_concurrent_executions
  layers                         = var.lambda_insights_arn
  tags                           = var.tags
  vpc_config {
    subnet_ids         = var.lambda_subnet_ids
    security_group_ids = var.security_group_ids
  }
  environment {
    variables = var.env_variables
  }
  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_lambda_function_url" "function_url" {
  count              = var.trigger == "cloudfront" ? 1 : 0
  function_name      = aws_lambda_function.lambda.function_name
  authorization_type = "NONE"

  dynamic "cors" {
    for_each = length(keys(var.cors)) == 0 ? [] : [var.cors]

    content {
      allow_credentials = try(cors.value.allow_credentials, null)
      allow_headers     = try(cors.value.allow_headers, null)
      allow_methods     = try(cors.value.allow_methods, null)
      allow_origins     = try(cors.value.allow_origins, null)
      expose_headers    = try(cors.value.expose_headers, null)
      max_age           = try(cors.value.max_age, null)
    }
  }
}

resource "aws_lambda_permission" "lambda" {
  statement_id           = var.trigger == "eventbridge" ? "AllowEventBridgeLambdaInvoke" : (var.trigger == "sqs" ? "AllowExecutionFromSQSQueue" : "AllowExecutionFromCloudfront")
  action                 = var.trigger == "cloudfront" ? "lambda:InvokeFunctionUrl" : "lambda:InvokeFunction"
  function_name          = aws_lambda_function.lambda.function_name
  principal              = var.trigger == "eventbridge" ? "events.amazonaws.com" : (var.trigger == "sqs" ? "sqs.amazonaws.com" : "cloudfront.amazonaws.com")
  source_arn             = var.source_arn
  function_url_auth_type = var.trigger == "cloudfront" ? "NONE" : null

}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  count            = var.trigger == "sqs" ? 1 : 0
  event_source_arn = var.source_arn
  enabled          = true
  function_name    = aws_lambda_function.lambda.arn
  batch_size       = var.batch_size

  scaling_config {
    maximum_concurrency = var.maximum_concurrency
  }

}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.logs_retention_in_days
  tags              = var.tags
}
