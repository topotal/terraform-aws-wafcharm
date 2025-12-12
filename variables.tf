variable "env" {
  type        = string
  description = "Environment name (e.g., dev, staging, production)"
}

variable "wafcharm_trusted_account_ids" {
  type        = list(string)
  description = "List of AWS Account IDs trusted by WafCharm (obtained from WafCharm console)"
}

variable "wafcharm_external_ids" {
  type        = list(string)
  description = "List of External IDs for WafCharm (obtained from WafCharm console)"
}

variable "waf_log_bucket_arn" {
  type        = string
  description = "ARN of the S3 bucket for WAF logs"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for resources"
  default     = {}
}
