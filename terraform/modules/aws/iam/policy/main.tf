data "aws_iam_policy_document" "policy_data" {
  statement {
    actions   = ["${var.policy_actions}"]
    effect    = "${var.policy_effect}"
    resources = ["${var.policy_resources}"]
  }
}

resource "aws_iam_policy" "policy" {
  name    = "${var.policy_name}"
  policy  = "${data.aws_iam_policy_document.policy_data.json}"
}