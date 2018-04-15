# Tags
variable "tag_account" {}

variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# User
variable "user_name" {}

variable "user_policy_count" {}

variable "user_policy_arns" {
  type = "list"
}

# Outputs
output "user_arn" {
  value = "${aws_iam_user.bot_user.arn}"
}

output "user_id" {
  value = "${aws_iam_user.bot_user.unique_id}"
}

output "access_key" {
  value = "${aws_iam_access_key.bot_key.id}"
}

output "secret_key" {
  value = "${aws_iam_access_key.bot_key.secret}"
}
