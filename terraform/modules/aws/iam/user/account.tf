resource "aws_iam_user" "user_user" {
  lifecycle {
    prevent_destroy = true
  }

  name = "${var.user_name}"
  path = "/user/"
}

resource "aws_iam_user_policy_attachment" "user_policy" {
  count       = "${length(var.user_policy)}"

  user        = "${aws_iam_user.user_user.name}"
  policy_arn  = "${element(var.user_policy, count.index)}"
}
