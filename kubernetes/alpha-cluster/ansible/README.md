# Base cluster provisioning

These playbooks are intended to provision a kubernetes cluster up to the point
at which the [kubernetes contrib playbooks](https://github.com/kubernetes/contrib/tree/master/ansible)
can take over and provision the kubernetes components.

## Operating system requirements

These playbooks assume that all kubernetes machines (master and node) will run
Fedora, while all storage machines will run OpenSUSE.

Fedora releases 23+ present some additional problems which require pre-installation of some
packages before these playbooks can be run successfully.

- `python`: python2, required by ansible
- `libselinux-python`: required to work with files on selinux enabled systems
- `python2-dnf`: needed to install anything at all
- `python-firewall`: needed to manage firewalld

## Preparing the inventory

### hosts file

The inventory file must be placed within `./inventory/hosts`.
Each node to be provisioned must be reachable via a resolvable
hostname, and the hostname of each such node must be added to
one of three groups which denote its role in the cluster:

 + masters
 + nodes
 + storage

e.g., an `./inventory/hosts` file might look like:
```
[masters]
kubmaster01

[nodes]
kubnode01
kubnode02

[storage]
kubvol01
```

### variables

Default variables are set in the `./inventory/group_vars/all` file,
and may be overidden by either modifying the file or by adding a group
specific group_vars file with a new value.

#### required

The following variables must be defined either in the `./inventory/group_vars/all`
file or in a group specific file for the group requiring the variable.

**zpool_device**: *required by*: storage -- Path to the device which will be
 used to create the container volumes zpool

#### optional

The following variables have defaults defined and may be optionally overridden.

**zpool_name**: *optional for*: storage -- Name of the zpool which will be
 created for container volumes

## Running the playbook

The ansible.cfg will connect to each node as the root user, so root access is
required.

Once the inventory is set correctly, the cluster can be provisioned by executing
`ansible-playbook ./cluster.yml`. If connecting to the nodes for the first time
and a root password must be entered, execute instead `ansible-playbook -k ./cluster.yml`

## TODO

Some known problems with the playbooks yet to be resolved

- the `lineinfile` module is not currently acting in an idempotent way, and re-adds
 the requested line every time
