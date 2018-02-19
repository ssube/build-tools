# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# DB
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}
variable "db_secgroups" {
  type = "list"
}
variable "db_subnets" {
  type = "list"
}

# Outputs
output "database_host" {
  value = "${aws_db_instance.db_instance.address}"
}
