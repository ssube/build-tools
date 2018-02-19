resource "aws_subnet" "managed_subnet" {
  count       = "${length(var.subnet_zones)}"

  vpc_id      = "${data.aws_vpc.cluster_vpc.id}"
  cidr_block  = "${element(var.subnet_cidr, count.index)}"

  availability_zone = "${element(var.subnet_zones, count.index)}"

  tags {
    account     = "${var.tag_account}"
    environment = "${var.tag_environment}"
    owner       = "${var.tag_owner}"
    project     = "${var.tag_project}"
  }
}