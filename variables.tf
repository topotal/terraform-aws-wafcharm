variable "env" {
  type        = string
  description = "Environment name (e.g., dev, staging, production)"
}

variable "web_acl_name" {
  type        = string
  description = "Name of the Web ACL"
}

variable "web_acl_region" {
  type        = string
  description = "Region of the Web ACL (e.g., ap-northeast-1, global for CloudFront)"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "waf_log_bucket_name" {
  type        = string
  description = "S3 bucket name for WAF logs (must start with 'aws-waf-logs-')"

  validation {
    condition     = can(regex("^aws-waf-logs-", var.waf_log_bucket_name))
    error_message = "The bucket name must start with 'aws-waf-logs-'."
  }
}

variable "lambda_runtime" {
  type        = string
  description = "Lambda runtime version"
  default     = "nodejs18.x"

  validation {
    condition     = can(regex("^nodejs(12|14|16|18)\\.x$", var.lambda_runtime))
    error_message = "Lambda runtime must be one of: nodejs12.x, nodejs14.x, nodejs16.x, nodejs18.x"
  }
}

variable "lambda_timeout" {
  type        = number
  description = "Lambda function timeout in seconds"
  default     = 60
}

variable "lambda_memory_size" {
  type        = number
  description = "Lambda function memory size in MB"
  default     = 128
}

variable "cloudwatch_log_retention_days" {
  type        = number
  description = "CloudWatch Logs retention period in days"
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for resources"
  default     = {}
}
