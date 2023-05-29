provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAUX46VJXMNAOJLM7K"
  secret_key = "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"
}

resource "aws_s3_bucket" "baalti" {
  bucket        = "xuv7000"
  force_destroy = true
  tags = {
    Name = "baalti"
  }
}


resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.baalti.id
  key    = "index.html"
  source = "/home/nay/work/deep-cloudfront/index.html"
  content_type = "text/html"
  acl = "public-read-write"
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.baalti.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["326213389784"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.baalti.arn,
      "${aws_s3_bucket.baalti.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.baalti.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.baalti.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.baalti.id
  acl    = "log-delivery-write"
}
###########################################################################################
resource "aws_cloudfront_origin_access_identity" "my-oai" {
  comment = "my-oai"
}
resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.baalti.id
  acl    = "log-delivery-write"
}

##########################################################################################



resource "aws_s3_bucket_policy" "prod_website" {
  bucket = aws_s3_bucket.baalti.id
  policy = <<POLICY
 
 {
    "Version": "2008-10-17",
    "Id": "PolicyForCloudFrontPrivateContent",
    "Statement": [
        {
            "Sid": "PublicRead",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::326213389784:role/mys3role"
            },
            "Action": ["s3:GetObject"],
            "Resource": "arn:aws:s3:::xuv7000/*"
        }
    ]
}
POLICY
}


###################################################################################
#i created iam role and used its ARN #
###################################################################################

locals {
  s3_origin_id = "myS3Origin"
}
