#jinja2: trim_blocks:False
# Backend
terraform {
  backend "s3" {
    bucket  = "{{ secrets.tags.project }}-{{ secrets.tags.env }}-state"
    key     = "{{ secrets.tags.project }}-{{ secrets.tags.env }}"
    region  = "{{ secrets.region.primary }}"
    profile = "{{ secrets.tags.project }}-{{ secrets.tags.env }}"
  }
}

# Providers
provider "aws" {
  profile = "{{ secrets.tags.project }}-{{ secrets.tags.env }}"
  region  = "{{ secrets.region.primary }}"
}

provider "aws" {
  alias   = "dns"
  profile = "{{ secrets.tags.project }}-dns"
  region  = "{{ secrets.region.primary }}"
}

provider "aws" {
  alias   = "replica"
  profile = "{{ secrets.tags.project }}-{{ secrets.tags.env }}"
  region  = "{{ secrets.region.replica }}"
}

provider "aws" {
  alias   = "site"
  profile = "{{ secrets.tags.project }}-{{ secrets.tags.env }}"
  region  = "{{ secrets.region.global }}"
}

# Tags
module "tags" {
  source = "{{ terraform_module }}/meta/tags"

  environment = "{{ secrets.tags.env }}"
  owner       = "{{ secrets.tags.owner }}"
  project     = "{{ secrets.tags.project }}"
}

module "cluster_network" {
  source = "{{ terraform_module }}/aws/vpc/network"

  subnet_cidr = [
    "{{ secrets.network.prefix }}.10.0/24",
    "{{ secrets.network.prefix }}.11.0/24",
    "{{ secrets.network.prefix }}.12.0/24",
  ]

  subnet_zones = [
    "{{ secrets.region.primary }}a",
    "{{ secrets.region.primary }}b",
    "{{ secrets.region.primary }}c",
  ]

  # remove these security groups while creating the k8s cluster
  peer_groups = [
    # {% if build_tools_cluster.peer %}
    "${module.cluster_k8s.master_security_group_ids}",

    "${module.cluster_k8s.node_security_group_ids}",

    # {% endif -%}
    "",
  ]

  vpc_id          = "{{ build_tools_cluster.network.id }}"
  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "website_bucket" {
  source = "{{ terraform_module }}/aws/s3/site_bucket"

  bucket_name   = "{{ secrets.dns.site }}"
  bucket_origin = "${module.website_site.site_principal}"

  region_primary = "{{ secrets.region.global }}"
  region_replica = "{{ secrets.region.replica }}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "website_site" {
  source = "{{ terraform_module }}/aws/cloudfront/site"

  cert_arn      = "{{ secrets.site.cert }}"
  site_aliases  = ["www.{{ secrets.dns.site }}"]
  source_bucket = "${module.website_bucket.bucket_domain}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "cluster_backup" {
  source = "{{ terraform_module }}/aws/s3/durable_bucket"

  bucket_name = "${module.tags.tag_project}-backup"

  bucket_writers = [
    "arn:aws:iam::${module.tags.tag_account}:root",

    # papertrail log writer
    "arn:aws:iam::719734659904:root",
  ]

  region_primary = "{{ secrets.region.primary }}"
  region_replica = "{{ secrets.region.replica }}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "runner_cache" {
  source = "{{ terraform_module }}/aws/s3/temporary_bucket"

  bucket_name = "${module.tags.tag_project}-runner-cache"

  bucket_writers = [
    "arn:aws:iam::${module.tags.tag_account}:root",
  ]

  region_primary = "{{ secrets.region.primary }}"
  region_replica = "{{ secrets.region.replica }}"

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

  db_name      = "gitlab"
  db_username  = "{{ secrets.database.user }}"
  db_password  = "${module.cluster_database_password.token_value}"
  db_secgroups = ["${module.cluster_network.managed_group}"]
  db_subnets   = ["${module.cluster_network.managed_subnets}"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_backup" {
  source = "{{ terraform_module }}/aws/iam/policy"

  policy_name = "{{ secrets.tags.project }}-backup"

  policy_actions = [
    "s3:GetObject",
    "s3:ListObjects",
    "s3:PutObject",
  ]

  policy_resources = [
    "arn:aws:s3:::${module.cluster_backup.bucket_name}",
    "arn:aws:s3:::${module.cluster_backup.bucket_name}/*",
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_cluster_dns_list" {
  source = "{{ terraform_module }}/aws/iam/policy"

  policy_name = "{{ secrets.tags.project }}-cluster-dns-list"

  policy_actions = [
    "route53:ListHostedZones",
  ]

  policy_resources = [
    "*",
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_cluster_dns_update" {
  source = "{{ terraform_module }}/aws/iam/policy"

  policy_name = "{{ secrets.tags.project }}-cluster-dns-update"

  policy_actions = [
    "route53:ChangeResourceRecordSets",
    "route53:ListResourceRecordSets",
  ]

  policy_resources = [
    "arn:aws:route53:::hostedzone/{{ secrets.dns.zone }}",
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_cluster_scaler" {
  source = "{{ terraform_module }}/aws/iam/policy"

  policy_name = "{{ secrets.tags.project }}-cluster-scaler"

  policy_actions = [
    "autoscaling:*",
  ]

  policy_resources = [
    "*",
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_gitlab_server" {
  source = "{{ terraform_module }}/aws/iam/policy"

  policy_name = "{{ secrets.tags.project }}-gitlab-server"

  # TODO: safely allow deleting cache objects
  policy_actions = [
    "s3:GetObject",
    "s3:ListBucket",
    "s3:ListObjects",
    "s3:PutObject",
  ]

  policy_resources = [
    "arn:aws:s3:::${module.cluster_backup.bucket_name}",
    "arn:aws:s3:::${module.cluster_backup.bucket_name}/*",
    "arn:aws:s3:::${module.runner_cache.bucket_name}",
    "arn:aws:s3:::${module.runner_cache.bucket_name}/*",
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_gitlab_runner" {
  source = "{{ terraform_module }}/aws/iam/policy"

  policy_name = "{{ secrets.tags.project }}-gitlab-runner"

  policy_actions = [
    "s3:*Object",
    "s3:ListBucket",
    "s3:ListObjects",
  ]

  policy_resources = [
    "arn:aws:s3:::${module.runner_cache.bucket_name}",
    "arn:aws:s3:::${module.runner_cache.bucket_name}/*",
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_gitlab_job" {
  source = "{{ terraform_module }}/aws/iam/policy"

  policy_name = "{{ secrets.tags.project }}-gitlab-job"

  policy_actions = [
    "s3:GetObject",
    "s3:ListObjects",
  ]

  policy_resources = [
    "arn:aws:s3:::${module.runner_cache.bucket_name}",
    "arn:aws:s3:::${module.runner_cache.bucket_name}/*",
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

# Roles
module "role_cluster_dns" {
  source = "{{ terraform_module }}/aws/iam/role"

  role_assume       = ["${module.cluster_k8s.nodes_role_arn}"]
  role_name         = "{{ secrets.tags.project }}-cluster-dns"
  role_policy_count = 2

  role_policy_arns = [
    "${module.policy_cluster_dns_list.policy_arn}",
    "${module.policy_cluster_dns_update.policy_arn}",
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "role_cluster_scaler" {
  source = "{{ terraform_module }}/aws/iam/role"

  role_assume       = ["${module.cluster_k8s.nodes_role_arn}"]
  role_name         = "{{ secrets.tags.project }}-cluster-scaler"
  role_policy_count = 1
  role_policy_arns  = ["${module.policy_cluster_scaler.policy_arn}"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "role_gitlab_server" {
  source = "{{ terraform_module }}/aws/iam/role"

  role_assume       = ["${module.cluster_k8s.nodes_role_arn}"]
  role_name         = "{{ secrets.tags.project }}-gitlab-server"
  role_policy_count = 1
  role_policy_arns  = ["${module.policy_gitlab_server.policy_arn}"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "role_gitlab_runner" {
  source = "{{ terraform_module }}/aws/iam/role"

  role_assume       = ["${module.cluster_k8s.nodes_role_arn}"]
  role_name         = "{{ secrets.tags.project }}-gitlab-runner"
  role_policy_count = 1
  role_policy_arns  = ["${module.policy_gitlab_runner.policy_arn}"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "role_gitlab_job" {
  source = "{{ terraform_module }}/aws/iam/role"

  role_assume       = ["${module.cluster_k8s.nodes_role_arn}"]
  role_name         = "{{ secrets.tags.project }}-gitlab-job"
  role_policy_count = 1
  role_policy_arns  = ["${module.policy_gitlab_job.policy_arn}"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

# {% for bot in secrets.users.bots %}
module "bot_{{ bot.name }}" {
  source = "{{ terraform_module }}/aws/iam/bot"

  user_name = "{{ bot.name }}"

  user_policy_count = "{{ bot.policy | length }}"

  user_policy_arns = [
    # {% for policy in bot.policy %}
    "${module.policy_{{ policy }}.policy_arn}",

    # {% endfor -%}
    "",
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

# {% endfor %}

module "cluster_output" {
  source = "{{ terraform_module }}/aws/s3/template_object"

  bucket_name = "${module.tags.tag_project}"

  object_name = "output.yml"

  object_body = <<EOF
output:
  backup:
    bucket:
      primary: ${module.cluster_backup.bucket_name}

  users:
    bots:
      # {% for bot in secrets.users.bots %}
      {{ bot.name }}:
        arn: ${module.bot_{{ bot.name }}.user_arn}
        id: ${module.bot_{{ bot.name }}.user_id}
        # {% if bot.creds %}
        access_key: ${module.bot_{{ bot.name }}.access_key}
        secret_key: ${module.bot_{{ bot.name }}.secret_key}
        # {% endif %}
      # {% endfor %}

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
