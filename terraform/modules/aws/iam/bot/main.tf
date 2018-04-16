resource "aws_iam_user" "bot_user" {
  name = "${var.user_name}"
  path = "/bot/"
}

resource "aws_iam_access_key" "bot_key" {
  user = "${aws_iam_user.bot_user.name}"
}

resource "aws_iam_user_policy_attachment" "bot_policy" {
  count = "${var.user_policy_count}"

  user       = "${aws_iam_user.bot_user.name}"
  policy_arn = "${element(var.user_policy_arns, count.index)}"
}
