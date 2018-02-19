resource "aws_iam_role" "replication" {
  name = "${var.bucket_name}-replica-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "replication" {
  name = "${var.bucket_name}-replica-policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket_primary.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket_primary.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bucket_replica.arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_policy_attachment" "replication" {
  name       = "${var.bucket_name}-replica-attach"
  roles      = ["${aws_iam_role.replication.name}"]
  policy_arn = "${aws_iam_policy.replication.arn}"
}

resource "aws_s3_bucket" "bucket_replica" {
  provider = "aws.replica"

  bucket   = "${var.bucket_name}-${var.tag_environment}-replica"
  region   = "${var.region_replica}"

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id      = "retire"
    enabled = true
    prefix  = "/"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }
  }

  versioning {
    enabled = true
  }

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}

resource "aws_s3_bucket" "bucket_primary" {
  bucket   = "${var.bucket_name}-${var.tag_environment}-primary"
  acl      = "private"
  region   = "${var.region_primary}"

  lifecycle {
    prevent_destroy = true
  }

  lifecycle_rule {
    id      = "retire"
    enabled = true
    prefix  = "/"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 180
    }
  }

  versioning {
    enabled = true
  }

  replication_configuration {
    role = "${aws_iam_role.replication.arn}"

    rules {
      id     = "${var.bucket_name}-replica"
      prefix = ""
      status = "Enabled"

      destination {
        bucket        = "${aws_s3_bucket.bucket_replica.arn}"
        storage_class = "STANDARD"
      }
    }
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