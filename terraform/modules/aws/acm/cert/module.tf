# Tags
variable "tag_account" {}
variable "tag_environment" {}
variable "tag_owner" {}
variable "tag_project" {}

# Cert
variable "cert_domain" {}

# Outputs
output "cert_arn" {
  value = "${data.aws_acm_certificate.acm_cert.arn}"
}
