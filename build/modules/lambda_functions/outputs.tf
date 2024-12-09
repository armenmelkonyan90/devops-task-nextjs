output "function_arn" {
  value = aws_lambda_function.lambda.arn
}

output "function_name" {
  value = aws_lambda_function.lambda.function_name
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.lambda_log_group.name
}

output "invoke_arn" {
  value = aws_lambda_function.lambda.invoke_arn
}

output "lambda_function_url_id" {
  value = var.trigger == "cloudfront" ? aws_lambda_function_url.function_url[0].url_id : ""
}
