# Getting Started

This Terraform module enables WafCharm's reporting and notification features by forwarding AWS WAF logs to WafCharm's S3 bucket.

## Overview

This module creates the following resources:

1. **S3 Bucket** - Storage for AWS WAF logs
2. **IAM Policy** - Read permissions for WAF log S3 bucket
3. **IAM Policy** - Put permissions for WafCharm integration S3 bucket
4. **IAM Role** - Execution role for Lambda function
5. **Lambda Function** - Forwards WAF logs to WafCharm S3
6. **CloudWatch Log Group** - Logs for Lambda function
7. **S3 Bucket Notification** - Trigger configuration for Lambda function

## Architecture

```
AWS WAF -> S3 (aws-waf-logs-*) -> Lambda -> WafCharm S3 (wafcharm.com)
                                    |
                                    v
                            CloudWatch Logs
```

## Basic Usage

Add the module to your Terraform configuration:

```hcl
module "wafcharm" {
  source = "github.com/topotal/terraform-aws-wafcharm"

  env            = "staging"
  aws_account_id = "123456789012"

  web_acl_name   = "my-web-acl"
  web_acl_region = "ap-northeast-1"  # Use "global" for CloudFront

  waf_log_bucket_name = "aws-waf-logs-my-wafcharm"

  lambda_runtime                = "nodejs18.x"
  lambda_timeout                = 60
  lambda_memory_size            = 128
  cloudwatch_log_retention_days = 30

  tags = {
    Service = "wafcharm"
  }
}
```

## Module Scope

### What This Module Handles

| Item | WafCharm Manual Reference |
|------|---------------------------|
| WAF log storage S3 bucket creation | 1.5 S3 bucket registration |
| WAF log S3 read permission policy | 2.2 WAFLog output destination read permission policy creation |
| WafCharm S3 put permission policy | 2.4 WafCharm integration put permission policy creation |
| Lambda IAM role | 2.6-2.8 WafCharm integration Lambda role creation |
| Lambda function | 2.9-2.13 Lambda setup |
| S3 event trigger | 2.11 Lambda setup (trigger) |
| CloudWatch Logs configuration | 2.14 CloudWatch |

### What Requires Manual Configuration

| Item | WafCharm Manual Reference | How to Configure |
|------|---------------------------|------------------|
| Web ACL Logging configuration | 1.1-1.7 Web ACL Logging and metrics settings | Terraform or AWS Console |
| Email notification recipients | 4.1-4.6 Email notification recipient settings | WafCharm Admin Console |
| Email notification ON/OFF | 4.7-4.9 Email notification settings | WafCharm Admin Console |

## Next Steps

After deploying this module, you need to:

1. **Configure Web ACL Logging** - See [Configuration Guide](configuration.md#web-acl-logging-configuration)
2. **Set up WafCharm notifications** (optional) - See [Configuration Guide](configuration.md#wafcharm-admin-console-settings)

## References

- [WafCharm Official Documentation](https://docs.wafcharm.com/)
- WafCharm PDF Manual (Reporting/Notification Features Manual Ver 1.2)
