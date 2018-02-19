data "aws_acm_certificate" "acm_cert" {
  domain    = "${var.cert_domain}"
  statuses  = ["ISSUED"]
}
