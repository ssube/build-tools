# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Bucket
variable "bucket_name" {}
variable "bucket_writers" {
  type = "list"
}

# Region
variable "region_primary" {}
variable "region_replica" {}

# Outputs
output "bucket_name" {
  value = "${aws_s3_bucket.bucket_primary.id}"
}
