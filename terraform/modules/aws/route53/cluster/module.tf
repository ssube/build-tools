# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Cluster
variable "cluster_name" {}

# Domain
variable "domain_name" {}
variable "domain_zone" {}

# Outputs
output "zone_id" {
  value = "${aws_route53_zone.cluster_zone.id}"
}

output "zone_name_servers" {
  value = "${aws_route53_zone.cluster_zone.name_servers}"
}
