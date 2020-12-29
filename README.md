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
