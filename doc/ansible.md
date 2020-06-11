# ops/ansible

The collection of Ansible playbooks in this repository
are used for performing ops team actions. All playbooks
can be executed using the ops-console, e.g.:

```
cd ansible
../script/console ansible-playbook [playbook-name]
```

## node-init.yml

This playbook should be run on newly provisioned instances.
It assumes that the first login must be performed as the root user
and handles initializing the server's Ansible environment
