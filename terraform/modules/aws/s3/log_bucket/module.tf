# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Bucket
variable "bucket_name" {}

# Outputs
output "bucket_id" {
  value = "${aws_s3_bucket.log_bucket.id}"
}

output "bucket_domain" {
  value = "${aws_s3_bucket.log_bucket.bucket_domain_name}"
}