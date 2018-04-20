# AWS

## Accounts

This project requires and creates resources in multiple AWS accounts. This works best with an organization and
consolidated billing. The accounts are structure like:

```none
root
  test
  prod
```

Account IDs may be found on the [support page](https://console.aws.amazon.com/support/home?region=us-east-1) for your
region. Most configuration uses the account ID.

You need to have a profile configured for the `root` account, with two additional CAA profiles for the other accounts.
In `~/.aws/config`:

```none
[profile test-net-root]
output = json
region = us-east-1

[profile test-net-prod]
role_arn = arn:aws:iam::12345678900:role/root-caa
source_profile = test-net-root

[profile test-net-test]
role_arn = arn:aws:iam::12345678901:role/root-caa
source_profile = test-net-root
```

With keys in `~/.aws/credentials`:

```none
[test-net-root]
aws_access_key_id =
aws_secret_access_key =
```

## Regions

The documentation uses `us-east-1` as an example only. Make sure to use the best region for your users.

Some resources, like Cloudfront certificates, need to be in `us-east-1`. Terraform handles the region for these
resources.

## Roles

The `root-caa` role must exist for any CAA to work.

To run the playbook, `root-caa` should have `AdministratorAccess` (or the equivalent permissions with specific
permissions). Each `root-caa` role in the `test` and `prod` accounts must have a trust relationship with the `root`
account.

## Sessions

With the role and profiles properly configured, you can log in to AWS (create an STS session) into an account using
the `aws-login` target and [`aws-create-session.sh`](../scripts/aws-create-session.sh) script.
