resource "aws_route53_zone" "cluster_zone" {
  name      = "${var.cluster_name}.${var.domain_name}"

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}

resource "aws_route53_record" "cluster_ns" {
  provider  = "aws.dns"

  name      = "${var.cluster_name}.${var.domain_name}"
  records   = [
    "${aws_route53_zone.cluster_zone.name_servers}"
  ]
  ttl       = 300
  type      = "NS"
  zone_id   = "${var.domain_zone}"
}
