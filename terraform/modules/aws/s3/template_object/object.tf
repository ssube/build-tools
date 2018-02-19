data "template_file" "template_template" {
  template = "${var.object_body}"

  vars {
    foo = "bar"
  }
}

resource "aws_s3_bucket_object" "template_object" {
  bucket  = "${var.bucket_name}-${var.tag_environment}-primary"
  key     = "${var.object_name}"
  content = "${data.template_file.template_template.rendered}"
  etag    = "${md5(data.template_file.template_template.rendered)}"
}