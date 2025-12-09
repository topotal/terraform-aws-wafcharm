# terraform-aws-wafcharm

Terraform module for [WafCharm](https://www.wafcharm.com/jp/) reporting and notification - transfers AWS WAF logs to WafCharm S3 for monthly reports and email alerts

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.13.0 |
| <a name="requirement_archive"></a> [archive](#requirement_archive)       | ~> 2.0    |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 6.17.0 |

## Providers

| Name                                                         | Version   |
| ------------------------------------------------------------ | --------- |
| <a name="provider_archive"></a> [archive](#provider_archive) | ~> 2.0    |
| <a name="provider_aws"></a> [aws](#provider_aws)             | ~> 6.17.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                                      | Type        |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_cloudwatch_log_group.wafcharm_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group)                                              | resource    |
| [aws_iam_policy.wafcharm_s3_put](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                  | resource    |
| [aws_iam_policy.waflog_s3_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                                                   | resource    |
| [aws_iam_role.wafcharm_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                                      | resource    |
| [aws_iam_role_policy_attachment.lambda_execute](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                                   | resource    |
| [aws_iam_role_policy_attachment.wafcharm_s3_put](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                                  | resource    |
| [aws_iam_role_policy_attachment.waflog_s3_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)                                   | resource    |
| [aws_lambda_function.wafcharm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function)                                                               | resource    |
| [aws_lambda_permission.s3_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission)                                                         | resource    |
| [aws_s3_bucket.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket)                                                                           | resource    |
| [aws_s3_bucket_lifecycle_configuration.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration)                           | resource    |
| [aws_s3_bucket_notification.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification)                                                 | resource    |
| [aws_s3_bucket_public_access_block.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block)                                   | resource    |
| [aws_s3_bucket_server_side_encryption_configuration.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource    |
| [aws_s3_bucket_versioning.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning)                                                     | resource    |
| [archive_file.wafcharm_lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file)                                                                   | data source |
| [aws_iam_policy_document.lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                                          | data source |

## Inputs

| Name                                                                                                                     | Description                                                         | Type          | Default        | Required |
| ------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------- | ------------- | -------------- | :------: |
| <a name="input_aws_account_id"></a> [aws_account_id](#input_aws_account_id)                                              | AWS Account ID                                                      | `string`      | n/a            |   yes    |
| <a name="input_cloudwatch_log_retention_days"></a> [cloudwatch_log_retention_days](#input_cloudwatch_log_retention_days) | CloudWatch Logs retention period in days                            | `number`      | `30`           |    no    |
| <a name="input_env"></a> [env](#input_env)                                                                               | Environment name (e.g., dev, staging, production)                   | `string`      | n/a            |   yes    |
| <a name="input_lambda_memory_size"></a> [lambda_memory_size](#input_lambda_memory_size)                                  | Lambda function memory size in MB                                   | `number`      | `128`          |    no    |
| <a name="input_lambda_runtime"></a> [lambda_runtime](#input_lambda_runtime)                                              | Lambda runtime version                                              | `string`      | `"nodejs18.x"` |    no    |
| <a name="input_lambda_timeout"></a> [lambda_timeout](#input_lambda_timeout)                                              | Lambda function timeout in seconds                                  | `number`      | `60`           |    no    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                            | Additional tags for resources                                       | `map(string)` | `{}`           |    no    |
| <a name="input_waf_log_bucket_name"></a> [waf_log_bucket_name](#input_waf_log_bucket_name)                               | S3 bucket name for WAF logs (must start with 'aws-waf-logs-')       | `string`      | n/a            |   yes    |
| <a name="input_web_acl_name"></a> [web_acl_name](#input_web_acl_name)                                                    | Name of the Web ACL                                                 | `string`      | n/a            |   yes    |
| <a name="input_web_acl_region"></a> [web_acl_region](#input_web_acl_region)                                              | Region of the Web ACL (e.g., ap-northeast-1, global for CloudFront) | `string`      | n/a            |   yes    |

## Outputs

| Name                                                                                                              | Description                                 |
| ----------------------------------------------------------------------------------------------------------------- | ------------------------------------------- |
| <a name="output_cloudwatch_log_group_name"></a> [cloudwatch_log_group_name](#output_cloudwatch_log_group_name)    | Name of the CloudWatch Log Group for Lambda |
| <a name="output_lambda_function_arn"></a> [lambda_function_arn](#output_lambda_function_arn)                      | ARN of the WafCharm Lambda function         |
| <a name="output_lambda_function_name"></a> [lambda_function_name](#output_lambda_function_name)                   | Name of the WafCharm Lambda function        |
| <a name="output_lambda_role_arn"></a> [lambda_role_arn](#output_lambda_role_arn)                                  | ARN of the Lambda IAM role                  |
| <a name="output_s3_log_prefix"></a> [s3_log_prefix](#output_s3_log_prefix)                                        | S3 prefix where WAF logs are stored         |
| <a name="output_waf_log_bucket_arn"></a> [waf_log_bucket_arn](#output_waf_log_bucket_arn)                         | ARN of the WAF log S3 bucket                |
| <a name="output_waf_log_bucket_domain_name"></a> [waf_log_bucket_domain_name](#output_waf_log_bucket_domain_name) | Domain name of the WAF log S3 bucket        |
| <a name="output_waf_log_bucket_id"></a> [waf_log_bucket_id](#output_waf_log_bucket_id)                            | ID of the WAF log S3 bucket                 |

<!-- END_TF_DOCS -->

