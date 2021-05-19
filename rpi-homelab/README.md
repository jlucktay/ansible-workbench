# Raspberry Pi Homelab

## Flow

1. [Update](playbooks/update-kube-packages.yaml)
1. [Initialise](playbooks/initialise.yaml)
1. [Teardown](playbooks/teardown.yaml)

## Requirements

The [initialise](playbooks/initialise.yaml) playbook requires the use of [`yq` v4+](https://github.com/mikefarah/yq) on
the executing machine (probably `localhost`) in order to merge the new kubeconfig file into your existing one.
