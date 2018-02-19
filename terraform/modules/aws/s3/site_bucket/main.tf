data "aws_iam_policy_document" "site_role_doc" {
  provider = "aws.site"

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    effect = "Allow"
  }
}

resource "aws_iam_role" "site_role" {
  provider = "aws.site"

  name   = "${var.tag_project}-${var.bucket_name}-role"
  assume_role_policy = "${data.aws_iam_policy_document.site_role_doc.json}"
}

data "aws_iam_policy_document" "site_policy_doc" {
  provider = "aws.site"

  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:ListBucket"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.site_bucket_primary.arn}"
    ]
  }

  statement {
    actions = [
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.site_bucket_primary.arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.site_bucket_replica.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "site_policy" {
  provider = "aws.site"

  name   = "${var.tag_project}-${var.bucket_name}-policy"
  policy = "${data.aws_iam_policy_document.site_policy_doc.json}"
}

resource "aws_iam_policy_attachment" "site_replication" {
  provider = "aws.site"

  name   = "${var.tag_project}-${var.bucket_name}-attachment"
  roles      = ["${aws_iam_role.site_role.name}"]
  policy_arn = "${aws_iam_policy.site_policy.arn}"
}

resource "aws_s3_bucket" "site_bucket_replica" {
  provider = "aws.replica"
  bucket = "${var.tag_project}-${var.bucket_name}-${var.tag_environment}-replica"
  region = "${var.region_replica}"

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

resource "aws_s3_bucket"  "site_bucket_primary" {
  provider = "aws.site"
  bucket = "${var.tag_project}-${var.bucket_name}-${var.tag_environment}-primary"
  region = "${var.region_primary}"

  replication_configuration {
    role = "${aws_iam_role.site_role.arn}"

    rules {
      id      = "site_replica"
      prefix  = ""
      status  = "Enabled"

      destination {
        bucket = "${aws_s3_bucket.site_bucket_replica.arn}"
        storage_class = "STANDARD"
      }
    }
  }

  website {
    index_document = "index.html"
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

data "aws_iam_policy_document" "site_policy_data" {
  statement {
    effect  = "Allow"
    actions = ["s3:GetObject"]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_s3_bucket.site_bucket_primary.arn}/*"
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["s3:ListBucket"]

    principals {
      type = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_s3_bucket.site_bucket_primary.arn}"
    ]
  }

}

resource "aws_s3_bucket_policy" "site_policy" {
  provider = "aws.site"
  bucket = "${aws_s3_bucket.site_bucket_primary.id}"
  policy = "${data.aws_iam_policy_document.site_policy_data.json}"
}
