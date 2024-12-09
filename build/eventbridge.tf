resource "aws_cloudwatch_event_rule" "warmer_function_rule" {
  name                = "${local.app_name}_warmer_function_cron"
  description         = "Cron job to trigger the warmer_function Lambda function"
  schedule_expression = "rate(5 minutes)"
  tags                = local.additional_tags
}

resource "aws_cloudwatch_event_target" "warmer_function_target" {
  depends_on = [module.warmer_function]
  rule       = aws_cloudwatch_event_rule.warmer_function_rule.name
  target_id  = "${var.app_name}_warmer_function_target"
  arn        = module.warmer_function.function_arn
}
