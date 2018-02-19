# Kubernetes

## Cluster Size

The default cluster is fairly small, with three masters and three server nodes. This is the smallest configuration for
high-availability, with a quorom of masters and a hot-spare server.

The cluster will run with a single master, but rolling updates will break and you will need to recreate the cluster.

To change the cluster size or node type, edit the `cluster.master` and `cluster.nodes` variables in
[`cluster.yml`](../../vars/gitlab.yml).
