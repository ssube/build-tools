
module "domain_zone" {
  source = "./modules/aws/route53/site"

  site_domain = "${var.domain_name}"
  site_origin = "${module.website_site.site_domain}"

  record_ttl  = 300

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "cluster_zone" {
  source = "./modules/aws/route53/cluster"

  cluster_name = "${module.tags.tag_project}"

  domain_name = "${var.domain_name}"
  domain_zone = "${module.domain_zone.zone_id}"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "domain_mx" {
  source = "./modules/aws/route53/record"

  site_domain = "${var.domain_name}"
  site_zone   = "${module.domain_zone.zone_id}"

  record_data = [
    "1 ASPMX.L.GOOGLE.COM",
    "5 ALT1.ASPMX.L.GOOGLE.COM",
    "5 ALT2.ASPMX.L.GOOGLE.COM",
    "10 ALT3.ASPMX.L.GOOGLE.COM",
    "10 ALT4.ASPMX.L.GOOGLE.COM"
  ]
  record_sub  = ""
  record_ttl  = 300
  record_type = "MX"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "domain_status" {
  source = "./modules/aws/route53/record"

  site_domain = "${var.domain_name}"
  site_zone   = "${module.domain_zone.zone_id}"

  record_data = ["stats.uptimerobot.com."]
  record_sub  = "status"
  record_ttl  = 300
  record_type = "CNAME"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "domain_git" {
  source = "./modules/aws/route53/record"

  site_domain = "${var.domain_name}"
  site_zone   = "${module.domain_zone.zone_id}"

  record_data = ["git.${module.tags.tag_project}.${var.domain_name}."]
  record_sub  = "git"
  record_ttl  = 300
  record_type = "CNAME"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "domain_metrics" {
  source = "./modules/aws/route53/record"

  site_domain = "${var.domain_name}"
  site_zone   = "${module.domain_zone.zone_id}"

  record_data = ["metrics.${module.tags.tag_project}.${var.domain_name}."]
  record_sub  = "metrics"
  record_ttl  = 300
  record_type = "CNAME"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "domain_keybase" {
  source = "./modules/aws/route53/record"

  site_domain = "${var.domain_name}"
  site_zone   = "${module.domain_zone.zone_id}"

  record_data = ["${var.keybase_proof}"]
  record_sub  = "_keybase"
  record_ttl  = 300
  record_type = "TXT"

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}
