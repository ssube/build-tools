# Common Policies
module "policy_admin" {
  source = "./modules/aws/iam/policy"

  policy_actions    = ["*"]
  policy_name       = "admin"
  policy_resources  = ["*"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"

}

module "policy_backup" {
  source = "./modules/aws/iam/policy"

  policy_actions = [
    "s3:AbortMultipartUpload",
    "s3:GetObject",
    "s3:ListBucket",
    "s3:ListBucketMultipartUploads",
    "s3:ListMultipartUploadParts",
    "s3:PutObject",
  ]
  policy_name       = "backup"
  policy_resources  = ["arn:aws:s3:::${var.tag_project}-*"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_deploy" {
  source = "./modules/aws/iam/policy"

  policy_actions = [
    "s3:AbortMultipartUpload",
    "s3:DeleteObject",
    "s3:GetObject",
    "s3:GetObjectVersion",
    "s3:ListBucket",
    "s3:ListBucketMultipartUploads",
    "s3:ListBucketVersions",
    "s3:ListMultipartUploadParts",
    "s3:PutObject",
    "s3:PutObjectTagging"
  ]
  policy_name       = "deploy"
  policy_resources  = ["arn:aws:s3:::${var.tag_project}-*"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_monitor" {
  source = "./modules/aws/iam/policy"

  policy_actions = [
    "cloudwatch:*"
  ]
  policy_name       = "monitor"
  policy_resources  = ["*"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_runner_cache" {
  source = "./modules/aws/iam/policy"

  policy_actions = [
    "s3:AbortMultipartUpload",
    "s3:GetObject",
    "s3:ListBucket",
    "s3:ListBucketMultipartUploads",
    "s3:ListMultipartUploadParts",
    "s3:PutObject",
  ]
  policy_name       = "runner-cache"
  policy_resources  = ["arn:aws:s3:::${var.tag_project}-*"]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "policy_terraform" {
  source = "./modules/aws/iam/policy"

  policy_actions = [
    "acm:*",
    "autoscaling:*",
    "cloudfront:*",
    "dynamodb:*",
    "ec2:*",
    "elasticache:*",
    "elasticloadbalancing:*",
    "iam:*",
    "rds:*",
    "route53:*",
    "s3:*"
  ]
  policy_name = "terraform"
  policy_resources = [
    "*"
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

# Service accounts
module "bot_backup" {
  source = "./modules/aws/iam/bot"

  user_name   = "backup"
  user_policy = [
    "${module.policy_backup.policy_arn}"
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "bot_deploy" {
  source = "./modules/aws/iam/bot"

  user_name   = "deploy"
  user_policy = [
    "${module.policy_deploy.policy_arn}"
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "bot_monitor" {
  source = "./modules/aws/iam/bot"

  user_name   = "monitor"
  user_policy = [
    "${module.policy_monitor.policy_arn}"
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

module "bot_runner" {
  source = "./modules/aws/iam/bot"

  user_name   = "runner"
  user_policy = [
    "${module.policy_runner_cache.policy_arn}"
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}

# User accounts
module "user_owner" {
  source = "./modules/aws/iam/user"

  user_name   = "${module.tags.tag_owner}"
  user_policy = [
    "${module.policy_admin.policy_arn}",
    "${module.policy_terraform.policy_arn}"
  ]

  tag_account     = "${module.tags.tag_account}"
  tag_environment = "${module.tags.tag_environment}"
  tag_owner       = "${module.tags.tag_owner}"
  tag_project     = "${module.tags.tag_project}"
}
