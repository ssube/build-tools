resource "aws_vpc" "cluster_vpc" {
  cidr_block    = "${var.vpc_cidr}"

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}

resource "aws_internet_gateway" "cluster_gw" {
  vpc_id        = "${aws_vpc.cluster_vpc.id}"

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}