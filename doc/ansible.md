# ops/ansible

The collection of Ansible playbooks in this repository
are used for performing ops team actions. All playbooks
can be executed using the ops-console, e.g.:

```
cd ansible
../script/console ansible-playbook [playbook-name]
```

## Playbooks

### onboard-node.yml

This playbook will run all of the steps necessary to configure a
brand new host to run docker-compose projects. This is the playbook 
which should be run against any newly provisioned instances.
This playbook will execute the following workflow:

- node-init.yml
- node-patch.yml
- node-base.yml

### node-init.yml

This playbook handles initializing a new server's Ansible environment.
It assumes that the first login must be performed as the root user.
This playbook should only run successfully once, as it will disable
root user logins as its final action.

### node-patch.yml

This playbook will perform patching on any hosts it is run against
and reboot them if they have been patched. It operates on one host
at a time and fails if there is any failure on the host.

### node-base.yml

This playbook installs the base software and performs the server
environment configurations needed in order for the node to run
docker projects.
