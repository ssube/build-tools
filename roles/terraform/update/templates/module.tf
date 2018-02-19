variable "tag_environment" {}
variable "tag_project" {}
variable "tag_owner" {}

variable "domain_name" {}
variable "domain_zone" {}

variable "keybase_proof" {}

# Regions and zones
variable "region_global" {}
variable "region_primary" {}
variable "region_replica" {}

variable "zones_primary" {
  type = "list"
}

variable "zones_replica" {
  type = "list"
}

variable "site_cert" {}

variable "database_name" {}
variable "database_user" {}
