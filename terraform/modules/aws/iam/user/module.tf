# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# User
variable "user_name" {}
variable "user_policy" {
  type = "list"
}

# Outputs
output "user_arn" {
  value = "${aws_iam_user.user_user.arn}"
}

output "user_id" {
  value = "${aws_iam_user.user_user.unique_id}"
}
