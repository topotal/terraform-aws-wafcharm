# terraform-aws-wafcharm

Terraform module for [WafCharm](https://www.wafcharm.com/jp/) IAM Role - creates IAM role and policies required for WafCharm integration

> **Note:** This module supports **WafCharm New Plan with AWS WAF v2 Advanced Rule Policy** only.
>
> The following configurations are **not supported**:
>
> - AWS WAF Classic (only available with Legacy Plan, cannot migrate to New Plan)
> - AWS WAF v2 + Legacy Rule Policy (requires multiple credentials and Lambda integration)
> - WafCharm Lite (separate product used with CSC Managed Rules)
>
> For more details on WafCharm plans and rule policies, see:
>
> - [Differences between Advanced Rule Policy and Legacy Rule Policy](https://console.wafcharm.com/en/help/advanced_rule_policy_vs_legacy_rule_policy_en)

## Usage

```hcl
module "wafcharm" {
  source = "github.com/topotal/terraform-aws-wafcharm"

  env                          = "production"
  wafcharm_trusted_account_ids = ["123456789012"]  # From WafCharm console
  wafcharm_external_ids        = ["your-external-id"]  # From WafCharm console
  waf_log_bucket_arn           = "arn:aws:s3:::aws-waf-logs-your-bucket"

  tags = {
    Environment = "production"
  }
}
```

<!-- BEGIN_TF_DOCS -->

## Requirements

| Name                                                                     | Version   |
| ------------------------------------------------------------------------ | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | ~> 1.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                   | ~> 6.17.0 |

## Providers

| Name                                             | Version   |
| ------------------------------------------------ | --------- |
| <a name="provider_aws"></a> [aws](#provider_aws) | ~> 6.17.0 |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                  | Type        |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.wafcharm_s3_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)                                             | resource    |
| [aws_iam_role.wafcharm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role)                                                         | resource    |
| [aws_iam_role_policy_attachment.wafcharm_cloudwatch_readonly](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource    |
| [aws_iam_role_policy_attachment.wafcharm_s3_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)             | resource    |
| [aws_iam_role_policy_attachment.wafcharm_waf_full_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment)     | resource    |
| [aws_iam_policy_document.wafcharm_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                    | data source |
| [aws_iam_policy_document.wafcharm_s3_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                        | data source |

## Inputs

| Name                                                                                                                  | Description                                                                  | Type           | Default | Required |
| --------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------- | -------------- | ------- | :------: |
| <a name="input_env"></a> [env](#input_env)                                                                            | Environment name (e.g., dev, staging, production)                            | `string`       | n/a     |   yes    |
| <a name="input_tags"></a> [tags](#input_tags)                                                                         | Additional tags for resources                                                | `map(string)`  | `{}`    |    no    |
| <a name="input_waf_log_bucket_arn"></a> [waf_log_bucket_arn](#input_waf_log_bucket_arn)                               | ARN of the S3 bucket for WAF logs                                            | `string`       | n/a     |   yes    |
| <a name="input_wafcharm_external_ids"></a> [wafcharm_external_ids](#input_wafcharm_external_ids)                      | List of External IDs for WafCharm (obtained from WafCharm console)           | `list(string)` | n/a     |   yes    |
| <a name="input_wafcharm_trusted_account_ids"></a> [wafcharm_trusted_account_ids](#input_wafcharm_trusted_account_ids) | List of AWS Account IDs trusted by WafCharm (obtained from WafCharm console) | `list(string)` | n/a     |   yes    |

## Outputs

| Name                                                                                      | Description                                          |
| ----------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| <a name="output_wafcharm_role_arn"></a> [wafcharm_role_arn](#output_wafcharm_role_arn)    | IAM Role ARN for registering to the WafCharm console |
| <a name="output_wafcharm_role_name"></a> [wafcharm_role_name](#output_wafcharm_role_name) | IAM Role name for WafCharm                           |

<!-- END_TF_DOCS -->
