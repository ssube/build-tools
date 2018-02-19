resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.tag_project}-${var.bucket_name}"

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}