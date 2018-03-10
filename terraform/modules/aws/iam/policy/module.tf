# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Policy
variable "policy_actions" {
  type = "list"
}
variable "policy_name" {}
variable "policy_resources" {
  type = "list"
}

# Output
output "policy_arn" {
  value = "${aws_iam_policy.policy.arn}"
}