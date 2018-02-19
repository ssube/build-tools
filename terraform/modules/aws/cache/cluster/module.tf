# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Cache
variable "cache_name" {}
variable "cache_secgroups" {
  type = "list"
}
variable "cache_subnets" {
  type = "list"
}

# Output
output "cache_hosts" {
  value = "${aws_elasticache_cluster.cache_cluster.cache_nodes}"
}
