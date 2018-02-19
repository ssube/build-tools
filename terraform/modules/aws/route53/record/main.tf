resource "aws_route53_record" "site_record" {
  provider  = "aws.dns"
  name      = "${var.record_sub}${var.record_sub == "" ? "" : "."}${var.site_domain}"
  records   = ["${var.record_data}"]
  ttl       = "${var.record_ttl}"
  type      = "${var.record_type}"
  zone_id   = "${var.site_zone}"
}