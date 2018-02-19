# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Site Zone
variable "site_domain" {}
variable "site_zone" {}

# Record
variable "record_data" {
  type = "list"
}
variable "record_provider" {
  default = "aws.dns"
}
variable "record_sub" {}
variable "record_ttl" {}
variable "record_type" {}