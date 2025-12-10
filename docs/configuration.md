# Configuration Guide

This guide covers the additional configuration required after deploying the WafCharm module.

## Web ACL Logging Configuration

**Important:** This module does not include Web ACL Logging configuration. You must configure it separately using either Terraform or the AWS Console.

### Option 1: Configure with Terraform

```hcl
# Reference existing Web ACL
data "aws_wafv2_web_acl" "main" {
  name  = "my-web-acl"
  scope = "REGIONAL"  # Use "CLOUDFRONT" for CloudFront distributions
}

# Web ACL Logging configuration
resource "aws_wafv2_web_acl_logging_configuration" "wafcharm" {
  log_destination_configs = [module.wafcharm.waf_log_bucket_arn]
  resource_arn            = data.aws_wafv2_web_acl.main.arn

  # Note: Log filtering is generally not recommended for WafCharm
  # See: PDF Manual Chapter 6 - Additional Notes
}
```

### Option 2: Configure via AWS Console

1. Navigate to **WAF & Shield** > **Web ACLs**
2. Select the target Web ACL
3. Go to the **Logging and metrics** tab
4. Click **Enable logging**
5. Select **S3 bucket** as the Logging destination
6. Choose the S3 bucket created by this module
7. Click **Save**

## WafCharm Admin Console Settings

The following settings must be configured manually through the WafCharm admin console. These cannot be automated via Terraform.

### Reporting Feature

- **No configuration required** - automatically enabled
- Monthly reports are available at the beginning of each month for the previous month
- Reports are not generated if no detections occurred in the previous month

### Email Notification Feature

To enable email notifications:

1. Log in to the **WafCharm admin console**
2. Navigate to **Web ACL Config** and select the target Web ACL
3. Click **Notification**
4. Click **Edit** next to **Notification email**
5. Enter notification email addresses (up to 10 addresses)
6. Click **Update**
7. Click **Edit** again
8. Set **WafCharm Email Notification** to **ON**
9. Click **Save**

### Email Notification Details

| Setting | Value |
|---------|-------|
| Notification interval | Depends on WAF to S3 output interval (5 minutes) |
| Max detections per email | 10 |
| Sender address | `wafcharm-notification@cscloud.co.jp` |
| Recipient format | BCC |
