# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# VPC
variable "vpc_cidr" {}

# Subnets
variable "subnet_cidr" {
  type = "list"
}

variable "subnet_zones" {
  type = "list"
}

# Peers
variable "peer_groups" {
  type = "list"
}

# Output
output "managed_group" {
  value = "${aws_security_group.cluster_managed.id}"
}

output "managed_subnets" {
  value = ["${aws_subnet.managed_subnet.*.id}"]
}

output "vpc_id" {
  value = "${aws_vpc.cluster_vpc.id}"
}
