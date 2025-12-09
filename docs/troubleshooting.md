# Troubleshooting & Important Notes

## Important Notes

### S3 Lifecycle Policy

This module includes a pre-configured S3 lifecycle policy:

- **30 days**: Transition to Glacier storage class
- **365 days**: Permanent deletion

Modify these settings as needed for your retention requirements.

### Lambda Function Code

- The Lambda function uses AWS SDK v3
- If you prefer to use the official WafCharm code (`http://docs.wafcharm.com/manual/new_aws_waf/index.js`), replace the contents of `lambda/index.js`

### Log Filtering

AWS WAF log filtering is **not recommended** for WafCharm integration:

| Filter Setting | Impact |
|----------------|--------|
| `action: Block` only | Reports will only include BLOCK logs |
| `action: Count` only | Notifications and monthly reports will not function correctly |

### Lambda Permission Changes

If you modify the Lambda role (policy) permissions after the function is running, changes may not be reflected in the active Lambda instance.

**Solution:** Make a minor modification to `lambda/index.js` and redeploy to force the Lambda to pick up the new permissions.

## Troubleshooting

### Verifying Log Forwarding

1. **Check S3 bucket for WAF logs**
   - Verify that logs are being written to your WAF log S3 bucket

2. **Check CloudWatch Logs for errors**
   ```
   CloudWatch > Log groups > /aws/lambda/<function-name>
   ```

### Common Errors

| Error | Cause | Solution |
|-------|-------|----------|
| `AccessDenied` | Insufficient IAM permissions | Review IAM policies, redeploy Lambda |
| `NoSuchBucket` | S3 bucket name mismatch | Verify bucket name configuration |
| `Lambda timeout` | Processing time exceeded | Increase `lambda_timeout` value |

### Debugging Steps

1. **Verify S3 bucket exists and is accessible**
   ```bash
   aws s3 ls s3://your-waf-log-bucket-name/
   ```

2. **Check Lambda function logs**
   ```bash
   aws logs tail /aws/lambda/wafcharm-your-env --follow
   ```

3. **Verify IAM role has correct permissions**
   - Check that the Lambda execution role has the required S3 read/write permissions
   - Ensure the trust relationship allows Lambda to assume the role

4. **Test Lambda function manually**
   - Use the AWS Console to create a test event
   - Check the execution results and logs

## Getting Help

- [WafCharm Official Documentation](https://docs.wafcharm.com/)
- Contact WafCharm support for integration-specific issues
