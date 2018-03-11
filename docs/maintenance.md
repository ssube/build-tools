# Maintenance

## In Case Of Emergency

**TODO:** this is fine

### Restore From Backup

The only service with a backup is Gitlab. You can restore that archive to a running pod using
[the `gitlab-restore` make target](gitlab.md#restore).

## Regular Updates

Every stage has an update target, like `make cluster-update`. This will fetch state, render templates, and update the
cloud resources to match.

Most updates are handling within Terraform, which provides good (but not perfect) diffs for your cloud resources. If
Terraform becomes confused, it can be useful to run the `make terraform-update` target directly and examine that diff.

Most services will gracefully handle upgrades, but the pod may not be replaced right away.

**TODO:** provide a way to roll pods before exiting

## Interactive Updates

While rare, you may want to log into a shell pod or the cluster dashboard.

**Note:** If you are using CAA profiles, you will need to create a session token using the AWS tools and set that
in your environment before exporting the cluster context.

- create session
- export context
- local proxy
- cluster shell
