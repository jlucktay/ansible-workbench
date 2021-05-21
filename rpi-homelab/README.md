# Raspberry Pi Homelab

Ansible playbooks to update, initialise, and teardown a K8s cluster with exactly one control plane, and zero to many
worker nodes.

The Kubernetes version used will be the latest non-prerelease patch of the second-highest minor version, according to
the GitHub repository. See the [k8s-releases](./k8s-releases.sh) script for more details.

## Usage

By default, all nodes in the inventory's `worker` group will be joined to the cluster as workers.
Please check/update [the inventory file](inventory.yaml) as appropriate before running any playbooks.

If the initialise and teardown plays are run with the `cp_only` tag, then no worker nodes will be involved.

### Flow

1. [Update](playbooks/update-kube-packages.yaml): `ansible-playbook playbooks/update-kube-packages.yaml`
1. [Initialise](playbooks/initialise.yaml): `ansible-playbook playbooks/initialise.yaml`
    - alternately, for a single-node/CP-only "cluster": `ansible-playbook --tags cp_only playbooks/initialise.yaml`
1. [Teardown](playbooks/teardown.yaml): `ansible-playbook playbooks/teardown.yaml`
    - alternately, for a single-node/CP-only "cluster": `ansible-playbook --tags cp_only playbooks/teardown.yaml`

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
