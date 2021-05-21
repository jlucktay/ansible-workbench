# Raspberry Pi Homelab

Ansible playbooks to initialise, teardown, and update a K8s cluster with exactly one control plane, and zero to many
worker nodes.

## Usage

By default, all nodes in the inventory's `worker` group will be joined to the cluster as workers.

If the initialise and teardown plays are run with the `cp_only` tag, then no worker nodes will be involved.

### Flow

1. [Update](playbooks/update-kube-packages.yaml)
1. [Initialise](playbooks/initialise.yaml)
1. [Teardown](playbooks/teardown.yaml)

## Requirements

The [initialise](playbooks/initialise.yaml) playbook requires the use of [`yq` v4+](https://github.com/mikefarah/yq) on
the executing machine (probably `localhost`) in order to merge the new kubeconfig file into your existing one.

## TODOs

- accommodate multiple CP nodes for HA
- refactor and reduce/boil down
  - make use of Ansible variables, instead of temporary files
- ~~install the metric server as part of the initialise play~~
  - ~~patch the `--kubelet-insecure-tls` arg into place~~
    ~~([ref](https://github.com/kubernetes-sigs/metrics-server/issues/131#issuecomment-516505683))~~
