# Backend
terraform {
  backend "s3" {
    bucket  = "{{ secrets.tags.project }}-{{ secrets.tags.environment }}-state"
    key     = "{{ secrets.tags.project }}-{{ secrets.tags.environment }}"
    region  = "{{ secrets.region.primary }}"
    profile = "{{ secrets.tags.project }}-{{ secrets.tags.environment }}"
  }
}

# Providers
provider "aws" {
  profile = "{{ secrets.tags.project }}-{{ secrets.tags.environment }}"
  region  = "{{ secrets.region.primary }}"
}

provider "aws" {
  alias   = "dns"
  profile = "apex-root-caa"
  region  = "{{ secrets.region.primary }}"
}

provider "aws" {
  alias   = "replica"
  profile = "{{ secrets.tags.project }}-{{ secrets.tags.environment }}"
  region  = "{{ secrets.region.replica }}"
}

provider "aws" {
  alias   = "site"
  profile = "{{ secrets.tags.project }}-{{ secrets.tags.environment }}"
  region  = "{{ secrets.region.global }}"
}

# Tags
module "tags" {
  source = "{{ terraform_module }}/meta/tags"

  environment = "{{ secrets.tags.environment }}"
  owner       = "{{ secrets.tags.owner }}"
  project     = "{{ secrets.tags.project }}"
}

module "cluster_network" {
  source = "{{ terraform_module }}/aws/vpc/network"

  subnet_cidr   = [
    "{{ secrets.network.prefix }}.10.0/24",
    "{{ secrets.network.prefix }}.11.0/24",
    "{{ secrets.network.prefix }}.12.0/24"
  ]
  subnet_zones  = [
    "{{ secrets.region.primary }}a",
    "{{ secrets.region.primary }}b",
    "{{ secrets.region.primary }}c"
  ]

  # remove these security groups while creating the k8s cluster
  peer_groups = [
{% if cluster.peer %}
    "${module.cluster_k8s.master_security_group_ids}",
    "${module.cluster_k8s.node_security_group_ids}"
{% endif %}
  ]

  vpc_id = "{{ cluster.network.id }}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "website_bucket" {
  source = "{{ terraform_module }}/aws/s3/site_bucket"

  bucket_name     = "{{ cluster.dns.base }}"
  bucket_origin   = "${module.website_site.site_principal}"

  region_primary  = "{{ secrets.region.global }}"
  region_replica  = "{{ secrets.region.replica }}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "website_site" {
  source = "{{ terraform_module }}/aws/cloudfront/site"

  cert_arn      = "{{ secrets.site.cert }}"
  site_aliases  = ["www.{{ cluster.dns.base }}"]
  site_domain   = "{{ cluster.dns.base }}"
  source_bucket = "${module.website_bucket.bucket_domain}"

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

  region_primary  = "{{ secrets.region.primary }}"
  region_replica  = "{{ secrets.region.replica }}"

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

  region_primary  = "{{ secrets.region.primary }}"
  region_replica  = "{{ secrets.region.replica }}"

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

  cache_name      = "gitlab"
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

  db_name         = "gitlab"
  db_username     = "{{ secrets.database.user }}"
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

  cache:
    hosts: ${jsonencode(module.cluster_cache.cache_hosts)}

  cluster:
    name: ${module.cluster_k8s.cluster_name}

  database:
    host: ${module.cluster_database.database_host}
    name: gitlab
    user: {{ secrets.database.user }}
    pass: ${module.cluster_database_password.token_value}

  runner:
    cache:
      bucket:
        primary: ${module.runner_cache.bucket_name}
EOF

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}
