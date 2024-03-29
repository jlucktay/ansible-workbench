# Raspberry Pi Homelab

Ansible playbooks to provision, bootstrap, and update some Rasperry Pi hosts(s), and then initialise (and teardown, and
initialise, and ...) a K8s cluster with exactly one control plane, and zero to many worker nodes.

The Kubernetes version used will be the latest non-prerelease patch of the second-highest minor version, according to
the GitHub repository.
See the [k8s-release](./scripts/k8s-release.sh) script for more details.

## Usage

By default, all nodes in the inventory's `worker` group will be joined to the cluster as workers.
Please check/update [the inventory file](inventory.yaml) as appropriate before running any playbooks.

If the initialise and teardown plays are run with the `cp_only` tag, then no worker nodes will be involved.

### Flow

1. [Provision](playbooks/provision.yaml)

    - **NOTE [2022-07-11]:** this playbook is basically defunct, now that the latest release of Raspberry Pi OS does
      not create a default username/password to log in with, and the rpi-imager CLI flags aren't yet robust enough to
      supply all of the various values we want to load onto the SD card (public key, specific username/password, WiFi
      password); [reference](https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/)

    ```shell
    ansible-playbook playbooks/provision.yaml
    ```

    - note that this playbook uses some utilities and assumptions about paths that are specific to macOS
    - images an SD card for a fresh headless install
    - run once per SD card, moving each one in and out of the card reader between runs
    - TODO: the `wpa_supplicant.conf` file needs to be templated out, and the WiFi password put in a vault
      - see [here](https://www.digitalocean.com/community/cheatsheets/how-to-use-ansible-cheat-sheet-guide)
        under the *Using Ansible Vault to Store Sensitive Data* section

1. [Deploy public key](playbooks/deploy-public-key.yaml)

    - **NOTE [2022-07-11]:** this playbook is basically defunct, now that the latest release of Raspberry Pi OS does
      not create a default username/password to log in with, and the rpi-imager CLI flags aren't yet robust enough to
      supply all of the various values we want to load onto the SD card (public key, specific username/password, WiFi
      password); [reference](https://www.raspberrypi.com/news/raspberry-pi-bullseye-update-april-2022/)

    - **NOTE:** this playbook requires the `ANSIBLE_HOST_KEY_CHECKING` environment variable and the `--ask-pass` flag
      when executed

    ```shell
    ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --ask-pass playbooks/deploy-public-key.yaml
    ```

    - puts the public key from the local `.ssh/` directory into the remote `authorized_keys` file on each host in
      inventory
      - TODO: currently hard-coded to `$HOME/.ssh/id_rsa_rpi.pub`

1. [Bootstrap](playbooks/bootstrap.yaml)

    ```shell
    ansible-playbook playbooks/bootstrap.yaml
    ```

    - runs through some one-time (re)configuration tasks:
      - pull down [my dotfiles](https://github.com/jlucktay/dotfiles)
      - Linux system level
        - timezone
        - hostname
        - let `iptables` see bridged traffic
        - update/install various packages
        - etc etc
      - the Avahi daemon
        - publish host details with mDNS to enable discovery
      - if the host has the `hc_ping` variable defined, adds a health check cron job with <https://healthchecks.io>
        where this `hc_ping` variable should be set to the UUID of a check
      - add the Docker and Kubernetes `apt` repositories and associated signing keys

    - has some tags in place for cherry-picking various tasks

      ```shell
      $ ansible-playbook playbooks/bootstrap.yaml --list-tags

      playbook: playbooks/bootstrap.yaml

        play #1 (all): Bootstrapping - phase 1        TAGS: []
            TASK TAGS: [dotfiles, kubernetes, redundant-rpi-imager]

        play #2 (all): Bootstrapping - phase 2        TAGS: []
            TASK TAGS: [reboot1]

        play #3 (all): Bootstrapping - phase 3        TAGS: []
            TASK TAGS: [cron, kubernetes]

        play #4 (all): Bootstrapping - phase 4        TAGS: []
            TASK TAGS: [reboot2]
      ```

1. [Update Kubernetes packages](playbooks/update-kube-packages.yaml)

    ```shell
    ansible-playbook playbooks/update-kube-packages.yaml
    ```

    - runs a [helper script](scripts/k8s-release.sh) to divine the semver of the latest non-prerelease patch for the
      second-highest minor version of Kubernetes, hard-coded to major version 1, from the
      [GitHub releases](https://github.com/kubernetes/kubernetes/releases)
    - updates the `kubeadm`, `kubectl`, and `kubelet` packages on all nodes to this target release of Kubernetes
    - pulls images used by `kubeadm`
    - stores the Kubernetes target release semver in a [local temporary file](tmp/k8s-release-installed.txt) for future
      reference, so that it can skip the needless update and image pull plays when the target release is already
      installed

1. [Initialise cluster](playbooks/initialise-cluster.yaml)

    ```shell
    ansible-playbook playbooks/initialise-cluster.yaml
    ```

    - alternately, for a single-node/CP-only "cluster"

        ```shell
        ansible-playbook --tags cp_only playbooks/initialise-cluster.yaml
        ```

1. [Teardown cluster](playbooks/teardown-cluster.yaml)

    ```shell
    ansible-playbook playbooks/teardown-cluster.yaml
    ```

    - alternately, for a single-node/CP-only "cluster"

        ```shell
        ansible-playbook --tags cp_only playbooks/teardown-cluster.yaml
        ```

## Requirements

~~The [deploy public key](playbooks/deploy-public-key.yaml) playbook requires the use of `sshpass`~~
~~([man page](https://linux.die.net/man/1/sshpass) and~~
~~[macOS Homebrew formula](https://github.com/nunnun/homebrew-sshpass/compare)) on the executing machine (probably~~
~~`localhost`) in order to SSH into each remote host once using a password.~~

The [initialise cluster](playbooks/initialise-cluster.yaml) playbook requires the use of
[`yq` v4+](https://github.com/mikefarah/yq) on the executing machine (probably `localhost`) in order to merge the
newly-generated kubeconfig file into your existing one.

## TODOs

- accommodate multiple CP nodes for HA
- refactor and reduce/boil down
  - make use of Ansible variables, instead of temporary files
  - use roles structure
    - <https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html>
    - <https://docs.ansible.com/ansible/latest/user_guide/sample_setup.html>
    - <https://github.com/stancel/ansible-playbook-scaffolding>
- ~~install the metric server as part of the initialise play~~
  - ~~patch the `--kubelet-insecure-tls` arg into place~~
    ~~([ref](https://github.com/kubernetes-sigs/metrics-server/issues/131#issuecomment-516505683))~~
