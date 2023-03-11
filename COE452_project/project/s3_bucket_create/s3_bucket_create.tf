# data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# permissions for website access
data "aws_iam_policy_document" "website_access" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    resources = [aws_s3_bucket.main.arn,"${aws_s3_bucket.main.arn}/*"]
    actions   = ["s3:GetObject"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
# permissions for storing mails
data "aws_iam_policy_document" "store_mail" {
  statement {
    sid       = "AllowSESPuts"
    effect    = "Allow"
    # resources = ["${aws_s3_bucket.main.arn}/ses/*"]
    resources = ["${aws_s3_bucket.main.arn}/ses/*"]
    actions   = ["s3:PutObject"]

    condition {
      test     = "StringEquals"
      variable = "aws:Referer"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }
  }
}


resource "aws_s3_bucket" "main" {
  bucket = var.s3_bucket_name
  force_destroy = var.delete_all
}
resource "aws_s3_bucket_website_configuration" "main" {
  count = var.website_configuration? 1:0
  bucket = aws_s3_bucket.main.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}
resource "aws_s3_bucket_acl" "main" {
  bucket = aws_s3_bucket.main.id
  acl    = var.set_acl
}

resource "aws_s3_bucket_policy" "website_access" {
  count = var.permissions_for_website_access? 1:0
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.website_access.json 
}
resource "aws_s3_bucket_policy" "store_mail" {
  count = var.permissions_for_store_mail? 1:0
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.store_mail.json
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  count = var.permissions_for_store_mail? 1:0
  bucket = aws_s3_bucket.main.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}


