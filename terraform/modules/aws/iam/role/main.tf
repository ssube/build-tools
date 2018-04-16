data "aws_iam_policy_document" "service_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["${var.role_assume}"]
    }
  }
}

resource "aws_iam_role" "service_role" {
  name               = "${var.role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.service_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "service_role_attach" {
  count      = "${var.role_policy_count}"
  role       = "${aws_iam_role.service_role.name}"
  policy_arn = "${element(var.role_policy_arns, count.index)}"
}
