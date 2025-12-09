output "waf_log_bucket_id" {
  description = "ID of the WAF log S3 bucket"
  value       = aws_s3_bucket.waf_logs.id
}

output "waf_log_bucket_arn" {
  description = "ARN of the WAF log S3 bucket"
  value       = aws_s3_bucket.waf_logs.arn
}

output "waf_log_bucket_domain_name" {
  description = "Domain name of the WAF log S3 bucket"
  value       = aws_s3_bucket.waf_logs.bucket_domain_name
}

output "lambda_function_arn" {
  description = "ARN of the WafCharm Lambda function"
  value       = aws_lambda_function.wafcharm.arn
}

output "lambda_function_name" {
  description = "Name of the WafCharm Lambda function"
  value       = aws_lambda_function.wafcharm.function_name
}

output "lambda_role_arn" {
  description = "ARN of the Lambda IAM role"
  value       = aws_iam_role.wafcharm_lambda.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for Lambda"
  value       = aws_cloudwatch_log_group.wafcharm_lambda.name
}

output "s3_log_prefix" {
  description = "S3 prefix where WAF logs are stored"
  value       = local.s3_log_prefix
}
