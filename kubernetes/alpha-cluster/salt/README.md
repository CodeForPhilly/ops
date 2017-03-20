# Base cluster provisioning

This directory is a set of salt states which can be used to provision the base
systems of kubernetes alpha cluster nodes. These may be either uploaded and run
locally on each node, or uploaded to a salt master, to which each node is made
a minion. In either case, the salt-minion tool much be installed on each machine.

## Required pillar data

The only machines which need pillar data are storage machines, which require
the following pillars:

`storage.zpool_device`: The path to the device which will be used to create the
 container volume zpool

Additionally, the following optional pillars may be provided to override the
defaults:

`storage.zpool_name`: The name of the zpool to be created for container volumes
