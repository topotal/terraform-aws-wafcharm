output "wafcharm_role_arn" {
  description = "IAM Role ARN for registering to the WafCharm console"
  value       = aws_iam_role.wafcharm.arn
}

output "wafcharm_role_name" {
  description = "IAM Role name for WafCharm"
  value       = aws_iam_role.wafcharm.name
}
