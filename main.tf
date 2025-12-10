locals {
  resource_prefix = "wafcharm-${var.env}"
  s3_log_prefix   = "AWSLogs/${var.aws_account_id}/WAFLogs/${var.web_acl_region}/${var.web_acl_name}/"

  default_tags = {
    Environment = var.env
    Service     = "wafcharm"
    ManagedBy   = "terraform"
  }

  tags = merge(local.default_tags, var.tags)
}

###############################
# S3 Bucket for WAF Logs
###############################
resource "aws_s3_bucket" "waf_logs" {
  bucket = var.waf_log_bucket_name

  tags = merge(local.tags, {
    Name = var.waf_log_bucket_name
  })
}

resource "aws_s3_bucket_versioning" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  rule {
    id     = "archive-and-expire"
    status = "Enabled"

    filter {
      prefix = "AWSLogs/"
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

###############################
# IAM Policy - WAF Log S3 Read
###############################
resource "aws_iam_policy" "waflog_s3_read" {
  name        = "${local.resource_prefix}-waflog-s3-read"
  description = "Policy for reading WAF logs from S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.waf_logs.arn}/${local.s3_log_prefix}*"
      }
    ]
  })

  tags = local.tags
}

###############################
# IAM Policy - WafCharm S3 Put
###############################
resource "aws_iam_policy" "wafcharm_s3_put" {
  name        = "${local.resource_prefix}-waflog-s3-put"
  description = "Policy for putting objects to WafCharm S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "arn:aws:s3:::wafcharm.com/*"
      }
    ]
  })

  tags = local.tags
}

###############################
# IAM Role for Lambda
###############################
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "wafcharm_lambda" {
  name               = "${local.resource_prefix}-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_execute" {
  role       = aws_iam_role.wafcharm_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_iam_role_policy_attachment" "waflog_s3_read" {
  role       = aws_iam_role.wafcharm_lambda.name
  policy_arn = aws_iam_policy.waflog_s3_read.arn
}

resource "aws_iam_role_policy_attachment" "waflog_s3_put" {
  role       = aws_iam_role.wafcharm_lambda.name
  policy_arn = aws_iam_policy.waflog_s3_put.arn
}

###############################
# CloudWatch Log Group for Lambda
###############################
resource "aws_cloudwatch_log_group" "wafcharm_lambda" {
  name              = "/aws/lambda/${local.resource_prefix}-waflog"
  retention_in_days = var.cloudwatch_log_retention_days

  tags = local.tags
}

###############################
# Lambda Function
###############################
data "archive_file" "wafcharm_lambda" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    content  = file("${path.module}/lambda/index.js")
    filename = "index.js"
  }
}

resource "aws_lambda_function" "wafcharm" {
  function_name = "${local.resource_prefix}-waflog"
  description   = "WafCharm log transfer function - transfers WAF logs to WafCharm S3"

  filename         = data.archive_file.wafcharm_lambda.output_path
  source_code_hash = data.archive_file.wafcharm_lambda.output_base64sha256

  runtime     = var.lambda_runtime
  handler     = "index.handler"
  role        = aws_iam_role.wafcharm_lambda.arn
  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory_size

  environment {
    variables = {
      WAFCHARM_BUCKET = "wafcharm.com"
      WAF_VERSION     = "v2"
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.wafcharm_lambda,
    aws_iam_role_policy_attachment.lambda_execute,
    aws_iam_role_policy_attachment.waflog_s3_read,
    aws_iam_role_policy_attachment.wafcharm_s3_put,
  ]

  tags = local.tags
}

###############################
# Lambda Permission for S3
###############################
resource "aws_lambda_permission" "s3_trigger" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.wafcharm.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.waf_logs.arn
}

###############################
# S3 Bucket Notification
###############################
resource "aws_s3_bucket_notification" "waf_logs" {
  bucket = aws_s3_bucket.waf_logs.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.wafcharm.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = local.s3_log_prefix
  }

  depends_on = [aws_lambda_permission.s3_trigger]
}
