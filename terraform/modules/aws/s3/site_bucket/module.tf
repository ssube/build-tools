# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Bucket
variable "bucket_name" {}
variable "bucket_origin" {}

# Region
variable "region_primary" {}
variable "region_replica" {}

# Outputs
output "bucket_id" {
  value = "${aws_s3_bucket.site_bucket_primary.id}"
}

output "bucket_domain" {
  value = "${aws_s3_bucket.site_bucket_primary.bucket_domain_name}"
}