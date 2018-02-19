# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Site
variable "site_domain" {}
variable "site_origin" {}

# Record
variable "record_ttl" {}

# Outputs
output "zone_id" {
  value = "${aws_route53_zone.site_zone.zone_id}"
}