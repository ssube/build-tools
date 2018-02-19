# Method
variable "token_method" {
  default = "random"
}

variable "token_length" {
  default = 20
}

variable "token_safe" {
  # exclude special characters
  default = false
}

# Output
output "token_value" {
  value = "${random_string.token_value.result}"
}
