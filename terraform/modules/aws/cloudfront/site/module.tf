# Tags
variable "tag_account" {}

variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Certificate
variable "cert_arn" {}

# Site
variable "site_aliases" {
  type = "list"
}

# Source
variable "source_bucket" {}

# Outputs
output "site_domain" {
  value = "${aws_cloudfront_distribution.site_distro.domain_name}"
}

output "site_principal" {
  value = "${aws_cloudfront_origin_access_identity.site_identity.iam_arn}"
}
