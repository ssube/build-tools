data "aws_iam_policy_document" "bucket_writer_document" {
  statement {
    sid = "1"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}"
    ]
  }

  statement {
    sid = "2"

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "bucket_writer" {
  name    = "${var.bucket_name}-${var.tag_environment}-writer"
  path    = "/"
  policy  = "${data.aws_iam_policy_document.bucket_writer_document.json}"
}

data "aws_iam_policy_document" "bucket_reader_document" {
  statement {
    sid = "1"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}"
    ]
  }

  statement {
    sid = "2"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "bucket_reader" {
  name    = "${var.bucket_name}-${var.tag_environment}-reader"
  path    = "/"
  policy  = "${data.aws_iam_policy_document.bucket_reader_document.json}"
}