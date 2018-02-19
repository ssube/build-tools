resource "aws_route53_zone" "site_zone" {
  name      = "${var.site_domain}"

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}

