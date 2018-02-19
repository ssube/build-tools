variable "environment" {}
variable "project" {}
variable "owner" {}

# Account
data "aws_caller_identity" "current" {}

# Outputs
output "tag_account" {
  value = "${data.aws_caller_identity.current.account_id}"
}

output "tag_environment" {
  value = "${var.environment}"
}

output "tag_owner" {
  value = "${var.owner}"
}

output "tag_project" {
  value = "${var.project}"
}