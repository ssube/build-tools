# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Site
variable "site_domain" {}

# Outputs
output "zone_id" {
  value = "${aws_route53_zone.site_zone.zone_id}"
}

output "zone_name_servers" {
  value = "${aws_route53_zone.site_zone.zone_name_servers}"
}
