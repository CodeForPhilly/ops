# Base cluster provisioning

This directory is a set of salt states which can be used to provision the base
systems of kubernetes alpha cluster nodes. These may be either uploaded and run
locally on each node, or uploaded to a salt master, to which each node is made
a minion. In either case, the salt-minion tool much be installed on each machine.

## Required pillar data

The only machines which need pillar data are storage machines, which offer the
following pillars:

### Volume zpool

In order to create the zpool for container volumes, the following pillars will be
required:

`storage.zpool_device`: The path to the device which will be used to create the
 container volume zpool

Additionally, the following optional pillars may be provided to override the
defaults:

`storage.zpool_name`: The name of the zpool to be created for container volumes

### Container volumes

Containers with volumes also must have entries in pillar. The following pillar
data will create two exported volumes for a container named 'A'; one named '1',
and another named '2' which is set to unix owner `nobody:nobody` and mode `0700`
and overrides the default volume quota

```
storage:
  containers:
    - name: A
      volumes:
       - name: '1'
       - name: '2'
         user: nobody
         group: nobody
         mode: 700
         properties:
           quota: 1G
```

the only required parameter for each container and volume is the `name` property
