# Tags
module "tags" {
  source = "{{ terraform_module }}/meta/tags"

  environment = "${var.tag_environment}"
  owner       = "${var.tag_owner}"
  project     = "${var.tag_project}"
}

module "cluster_network" {
  source = "{{ terraform_module }}/aws/vpc/network"

  subnet_cidr   = [
    "{{ secrets.network.prefix }}.10.0/24",
    "{{ secrets.network.prefix }}.11.0/24",
    "{{ secrets.network.prefix }}.12.0/24"
  ]
  subnet_zones  = [
    "${var.zones_primary}", "${var.zones_replica}"
  ]

  # remove these security groups while creating the k8s cluster
  peer_groups = [
    "${module.cluster_k8s.master_security_group_ids}",
    "${module.cluster_k8s.node_security_group_ids}"
  ]

  vpc_id = "{{ cluster_vpc.vpc.id }}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "website_bucket" {
  source = "{{ terraform_module }}/aws/s3/site_bucket"

  bucket_name     = "${var.domain_name}"
  bucket_origin   = "${module.website_site.site_principal}"

  region_primary  = "${var.region_global}"
  region_replica  = "${var.region_replica}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "website_site" {
  source = "{{ terraform_module }}/aws/cloudfront/site"

  cert_arn      = "${var.site_cert}"
  site_aliases  = ["www.${var.domain_name}"]
  site_domain   = "${var.domain_name}"
  source_bucket = "${module.website_bucket.bucket_domain}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "cluster_state" {
  source = "{{ terraform_module }}/aws/s3/durable_bucket"

  bucket_name     = "${module.tags.tag_project}"
  bucket_writers  = [
    "arn:aws:iam::${module.tags.tag_account}:root"
  ]

  region_primary  = "${var.region_primary}"
  region_replica  = "${var.region_replica}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "cluster_backup" {
  source = "{{ terraform_module }}/aws/s3/durable_bucket"

  bucket_name     = "${module.tags.tag_project}-backup"
  bucket_writers  = [
    "arn:aws:iam::${module.tags.tag_account}:root",
    "arn:aws:iam::719734659904:root"  # papertrail log writer
  ]

  region_primary  = "${var.region_primary}"
  region_replica  = "${var.region_replica}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "runner_cache" {
  source = "{{ terraform_module }}/aws/s3/temporary_bucket"

  bucket_name     = "${module.tags.tag_project}-runner-cache"
  bucket_writers  = [
    "arn:aws:iam::${module.tags.tag_account}:root"
  ]

  region_primary  = "${var.region_primary}"
  region_replica  = "${var.region_replica}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "cluster_k8s" {
  source = "{{ output_dir.path }}/tf-cluster"
}

module "cluster_cache" {
  source = "{{ terraform_module }}/aws/cache/cluster"

  cache_name      = "${var.database_name}"
  cache_secgroups = ["${module.cluster_network.managed_group}"]
  cache_subnets   = ["${module.cluster_network.managed_subnets}"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "cluster_database_password" {
  source = "{{ terraform_module }}/meta/secure_token"
}

module "cluster_database" {
  source = "{{ terraform_module }}/aws/rds"

  db_name         = "${var.database_name}"
  db_username     = "${var.database_user}"
  db_password     = "${module.cluster_database_password.token_value}"
  db_secgroups    = ["${module.cluster_network.managed_group}"]
  db_subnets      = ["${module.cluster_network.managed_subnets}"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "cluster_output" {
  source = "{{ terraform_module }}/aws/s3/template_object"

  bucket_name = "${module.tags.tag_project}"

  object_name = "output.yml"
  object_body = <<EOF
output:
  backup:
    bucket:
      primary: ${module.cluster_backup.bucket_name}

    user:
      access_key: ${module.bot_backup.access_key}
      secret_key: ${module.bot_backup.secret_key}

  cache:
    hosts: ${jsonencode(module.cluster_cache.cache_hosts)}

  cluster:
    name: ${module.cluster_k8s.cluster_name}

  database:
    host: ${module.cluster_database.database_host}
    name: ${var.database_name}
    user: ${var.database_user}
    pass: ${module.cluster_database_password.token_value}

  network:
    id: ${module.cluster_network.vpc_id}

  region:
    primary: ${var.region_primary}
    replica: ${var.region_replica}

  runner:
    cache:
      bucket:
        primary: ${module.runner_cache.bucket_name}

      user:
        access_key: ${module.bot_runner.access_key}
        secret_key: ${module.bot_runner.secret_key}
EOF

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}
