resource "aws_s3_bucket" "bucket_primary" {
  bucket   = "${var.bucket_name}-${var.tag_environment}-primary"
  acl      = "private"
  region   = "${var.region_primary}"

  lifecycle_rule {
    id      = "temporary-expire"
    enabled = true

    prefix  = "cache/"

    expiration {
      days = 7
    }
  }

  versioning {
    enabled = false
  }

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "${aws_s3_bucket.bucket_primary.id}"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "LogArchive",
            "Effect": "Allow",
            "Principal": {
                "AWS": ${jsonencode(var.bucket_writers)}
            },
            "Action": [
                "s3:DeleteObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${var.bucket_name}-${var.tag_environment}-primary/*"
            ]
        }
    ]
}
POLICY
}