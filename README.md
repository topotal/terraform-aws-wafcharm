# terraform-aws-wafcharm

Terraform module for [WafCharm](https://www.wafcharm.com/jp/) reporting and notification - transfers AWS WAF logs to WafCharm S3 for monthly reports and email alerts

## Documentation

- [Getting Started](docs/getting-started.md) - Overview, architecture, and basic usage
- [Configuration Guide](docs/configuration.md) - Web ACL Logging and WafCharm admin console settings
- [Troubleshooting](docs/troubleshooting.md) - Common issues and important notes

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.13.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | ~> 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.17.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | ~> 2.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.17.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.wafcharm_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.wafcharm_s3_put](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.waflog_s3_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.wafcharm_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_execute](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.waflog_s3_put](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.waflog_s3_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.wafcharm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.s3_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_s3_bucket.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_notification.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_public_access_block.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [archive_file.wafcharm_lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_iam_policy_document.lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS Account ID | `string` | n/a | yes |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch\_log\_retention\_days](#input\_cloudwatch\_log\_retention\_days) | CloudWatch Logs retention period in days | `number` | `30` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name (e.g., dev, staging, production) | `string` | n/a | yes |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | Lambda function memory size in MB | `number` | `128` | no |
| <a name="input_lambda_runtime"></a> [lambda\_runtime](#input\_lambda\_runtime) | Lambda runtime version | `string` | `"nodejs24.x"` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | Lambda function timeout in seconds | `number` | `60` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for resources | `map(string)` | `{}` | no |
| <a name="input_waf_log_bucket_name"></a> [waf\_log\_bucket\_name](#input\_waf\_log\_bucket\_name) | S3 bucket name for WAF logs (must start with 'aws-waf-logs-') | `string` | n/a | yes |
| <a name="input_web_acl_name"></a> [web\_acl\_name](#input\_web\_acl\_name) | Name of the Web ACL | `string` | n/a | yes |
| <a name="input_web_acl_region"></a> [web\_acl\_region](#input\_web\_acl\_region) | Region of the Web ACL (e.g., ap-northeast-1, global for CloudFront) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#output\_cloudwatch\_log\_group\_name) | Name of the CloudWatch Log Group for Lambda |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | ARN of the WafCharm Lambda function |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | Name of the WafCharm Lambda function |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | ARN of the Lambda IAM role |
| <a name="output_s3_log_prefix"></a> [s3\_log\_prefix](#output\_s3\_log\_prefix) | S3 prefix where WAF logs are stored |
| <a name="output_waf_log_bucket_arn"></a> [waf\_log\_bucket\_arn](#output\_waf\_log\_bucket\_arn) | ARN of the WAF log S3 bucket |
| <a name="output_waf_log_bucket_domain_name"></a> [waf\_log\_bucket\_domain\_name](#output\_waf\_log\_bucket\_domain\_name) | Domain name of the WAF log S3 bucket |
| <a name="output_waf_log_bucket_id"></a> [waf\_log\_bucket\_id](#output\_waf\_log\_bucket\_id) | ID of the WAF log S3 bucket |
<!-- END_TF_DOCS -->
