resource "aws_security_group" "cluster_managed" {
  name        = "cluster-managed"
  description = "allow traffic from managed services"
  vpc_id      = "${aws_vpc.cluster_vpc.id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "managed_peer_ingress" {
  count     = "${length(var.peer_groups)}"
  type      = "ingress"
  from_port = 0
  to_port   = 0
  protocol  = "all"

  security_group_id         = "${aws_security_group.cluster_managed.id}"
  source_security_group_id  = "${element(var.peer_groups, count.index)}"
}

resource "aws_security_group_rule" "managed_local_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "all"

  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.cluster_managed.id}"
}
