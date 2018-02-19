data "aws_vpc" "cluster_vpc" {
  id = "${var.vpc_id}"
}

resource "aws_internet_gateway" "cluster_gw" {
  vpc_id        = "${data.aws_vpc.cluster_vpc.id}"

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}