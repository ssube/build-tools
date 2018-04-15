# Changelog

This project is distributed as [an Ansible Galaxy role](https://galaxy.ansible.com/ssube/build-tools/) and does not
use Github or Gitlab releases.

This document provides a high-level changelog with compatibility notes for each tag. Breaking changes will be noted
here to help make upgrades easier.

## Releases

### Unstable

These releases may work but are not stable. Breaking changes will not cause major version number changes (it will
remain `0` until a stable release), but will be noted here. These may be used in production (under the terms of
[the license](./LICENSE.md)), but be careful.

#### 0.0.11

- [kube2iam](https://github.com/jtblin/kube2iam) for IAM roles in kops cluster
  - `cluster-iam` daemon
  - `cluster-iam` cluster role
  - iam roles for:
    - cluster dns
    - cluster scaler
    - gitlab server
    - gitlab runner
  - annotate services with the roles listed above
- use stable resource versions (replace `extensions/v1beta1` and `v1alpha2` stuff with `apps/v1`, `batch/v1`)
- gitlab config needs to be `b64encode`d *before* being passed to template (to preserve whitespace)

#### 0.0.10

- [kubernetes 1.10](https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-1.10.md)
- [gitlab 10.6.4](https://about.gitlab.com/2018/04/09/gitlab-10-6-4-released/)
- gitlab config and secrets (`/etc/gitlab`) use persistent storage (currently set to 4GB)
- website (TF `aws/cloudfront/site` module) uses a custom domain name and modern ciphers (`TLSv1_2016`)