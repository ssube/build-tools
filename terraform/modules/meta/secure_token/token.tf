resource "random_string" "token_value" {
  length = "${var.token_length}"
  special = "${var.token_safe}"
}
