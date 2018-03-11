data "aws_iam_policy_document" "policy_doc" {
  statement {
    actions = ["${var.policy_actions}"]
    effect = "Allow"
    resources = ["${var.policy_resources}"]
  }
}

resource "aws_iam_policy" "policy" {
  name = "${var.policy_name}"
  path = "/"
  description = "terraform policy ${var.policy_name}"

  policy = "${data.aws_iam_policy_document.policy_doc.json}"
}