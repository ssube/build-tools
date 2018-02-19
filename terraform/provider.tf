terraform {
  backend "s3" {
  }
}

provider "aws" {
  profile = "${var.tag_project}-${var.tag_environment}"
  region  = "${var.region_primary}"
}

provider "aws" {
  alias   = "dns"
  profile = "${var.tag_project}-root"
  region  = "${var.region_primary}"
}

provider "aws" {
  alias   = "replica"
  profile = "${var.tag_project}-${var.tag_environment}"
  region  = "${var.region_replica}"
}

provider "aws" {
  alias   = "site"
  profile = "${var.tag_project}-${var.tag_environment}"
  region  = "${var.region_global}"
}