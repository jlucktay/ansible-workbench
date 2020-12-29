# Ansible Workbench

Messing around with [Ansible](https://www.ansible.com).

## Check Mode

Run the playbook with the `--check` flag to see if any changes would be required, e.g.:

```shell
ansible-playbook playbooks/setup-app.yaml --check
```

## Tags

### Run only tagged tasks

#### Single tag

```shell
ansible-playbook playbooks/setup-app.yaml --tags upload
```

#### Multiple tags

```shell
ansible-playbook playbooks/setup-app.yaml --tags create,upload
```

### Skip over tagged tasks and run everything else

```shell
ansible-playbook playbooks/setup-app.yaml --skip-tags upload
```

## Ansible Vault

Ansible Vault gives us a secure method of storing secrets; they will be encrypted with a password, and can then be
checked in to source control.

### Create a new secrets file

```shell
ansible-vault create vars/secret-variables.yaml
```

### See its contents

```shell
ansible-vault view vars/secret-variables.yaml
```

### Use the secret variables

This command by itself will no longer work, now that it is making use of the secret variables file which Ansible Vault
has encrypted with a password:

```shell
ansible-playbook playbooks/setup-app.yaml
```

We must supply the `--ask-vault-pass` flag and go through the subsequent password prompt in order to access the secret
variables encrypted into this file:

```shell
ansible-playbook playbooks/setup-app.yaml --ask-vault-pass
```
