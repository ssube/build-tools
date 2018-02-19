resource "aws_route53_zone" "site_zone" {
  name      = "${var.site_domain}"
  provider  = "aws.dns"

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}

resource "aws_route53_record" "site_main" {
  name      = "www.${var.site_domain}"
  provider  = "aws.dns"
  records   = ["${var.site_origin}"]
  ttl       = "${var.record_ttl}"
  type      = "CNAME"
  zone_id   = "${aws_route53_zone.site_zone.zone_id}"
}