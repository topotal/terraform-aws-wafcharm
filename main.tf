# IAM Role Trust Policy obtained from the WafCharm console
data "aws_iam_policy_document" "wafcharm_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = var.wafcharm_trusted_account_ids
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = var.wafcharm_external_ids
    }
  }
}

# IAM Role
resource "aws_iam_role" "wafcharm" {
  name               = "WafCharmRole-${var.env}"
  description        = "IAM Role for WafCharm to manage AWS WAF rules"
  assume_role_policy = data.aws_iam_policy_document.wafcharm_assume_role.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "wafcharm_waf_full_access" {
  role       = aws_iam_role.wafcharm.name
  policy_arn = "arn:aws:iam::aws:policy/AWSWAFFullAccess"
}

data "aws_iam_policy_document" "wafcharm_s3_read" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    resources = [
      var.waf_log_bucket_arn,
      "${var.waf_log_bucket_arn}/*",
    ]
  }
}

resource "aws_iam_policy" "wafcharm_s3_read" {
  name        = "WafCharmS3Read-${var.env}"
  description = "Allow WafCharm to read WAF logs"
  policy      = data.aws_iam_policy_document.wafcharm_s3_read.json

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "wafcharm_s3_read" {
  role       = aws_iam_role.wafcharm.name
  policy_arn = aws_iam_policy.wafcharm_s3_read.arn
}

resource "aws_iam_role_policy_attachment" "wafcharm_cloudwatch_readonly" {
  role       = aws_iam_role.wafcharm.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
