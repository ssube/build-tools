# Terraform

This FAQ covers some questions about the Terraform architecture and common exceptions when using Terraform.

## Architecture

Modules are split by tool, which roughly matches Terraform's providers.

## Exceptions

### Computed Count

Terraform gets scared when it cannot determine the length of a list ahead of time.

This can be a problem for user and service accounts. Adding a profile and attaching it to an account in the same run
will trigger this error:

```none
Error: Error refreshing state: 1 error(s) occurred:

* module.user_owner.aws_iam_user_policy_attachment.user_policy: aws_iam_user_policy_attachment.user_policy: value of 'count' cannot be computed
```

To work around this, create the profile first (ready and apply), then attach it to users.

### No Such Bucket

S3 buckets are eventually consistent in some fashion, so you may see a `NoSuchBucket` error on the first run:

```none
Error: Error applying plan:

2 error(s) occurred:

* module.cluster_output.aws_s3_bucket_object.template_object: 1 error(s) occurred:

* aws_s3_bucket_object.template_object: Error putting object in S3 bucket (project-name-prod-primary): NoSuchBucket: The specified bucket does not exist
        status code: 404, request id: 1...6, host id: Q71...O4=
```

Let the Terraform run finish and, unless other errors are cause for concern, try again after a few minutes.

### Rename Module Resource

When renaming a resource, Terraform will usually see a removed resource and a newly added one, but does not make the
connection like a git rename. This can be a problem for users and resources that cannot easily be deleted.

This looks like:

```none
------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  - module.user_owner.aws_iam_user.account_user

  + module.user_owner.aws_iam_user.user_user
      id:            <computed>
      arn:           <computed>
      force_destroy: "false"
      name:          "owner"
      path:          "/user/"
      unique_id:     <computed>

  + module.user_owner.aws_iam_user_policy_attachment.user_policy
      id:            <computed>
      policy_arn:    "arn:aws:iam::1234567890:policy/terraform"
      user:          "owner"


Plan: 2 to add, 0 to change, 1 to destroy.

------------------------------------------------------------------------
```

Note that `account_user` was renamed to `user_user`, without changing any attributes in this case.

To fix this:

1. download the Terraform state from S3
1. rename the resource in place
1. upload the state, replacing the existing file

The plan should shows updates (if any) rather than creating a new resource. The state bucket is versioned, so this is
relatively safe, but be careful editing state by hand. `cat terraform.tfstate | jq` is a great way to validate before
you upload.
