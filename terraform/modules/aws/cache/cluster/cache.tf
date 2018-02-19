resource "aws_security_group" "cache_secgroup" {

}

resource "aws_elasticache_parameter_group" "cache_params" {
  name    = "${var.cache_name}-${var.tag_environment}-params"
  family  = "redis3.2"
}

resource "aws_elasticache_subnet_group" "cache_subnets" {
  name        = "${var.cache_name}-${var.tag_environment}-subnets"
  subnet_ids  = ["${var.cache_subnets}"]
}

resource "aws_elasticache_cluster" "cache_cluster" {
  cluster_id      = "${var.cache_name}-${var.tag_environment}"
  engine          = "redis"
  node_type       = "cache.t2.micro"
  num_cache_nodes = 1
  port            = 6379

  parameter_group_name  = "${aws_elasticache_parameter_group.cache_params.name}"
  security_group_ids    = ["${var.cache_secgroups}"]
  subnet_group_name     = "${aws_elasticache_subnet_group.cache_subnets.name}"

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}