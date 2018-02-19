# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Bucket
variable "bucket_name" {}

# Object
variable "object_body" {}
variable "object_name" {}

# Outputs
output "object_id" {
  value = "${aws_s3_bucket_object.template_object.id}"
}

output "object_version" {
  value = "${aws_s3_bucket_object.template_object.version_id}"
}
