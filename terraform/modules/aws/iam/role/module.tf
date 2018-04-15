# Tags
variable "tag_account" {}

variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Role
variable "role_name" {}

variable "role_principals" {
  type    = "list"
  default = ["ec2.amazonaws.com"]
}

variable "role_policy_count" {}

variable "role_policy_arns" {
  type = "list"
}
