# ops

Central place to create Code for Philly resources.

We handle requests through github issues.
You can create an issue to...

* [deploy a new application](https://github.com/CodeForPhilly/ops/issues/new?assignees=&labels=&template=new-application-deployment.md&title=Deploy+%5BAPP%5D)
* [create a new Code for Philly github repo](https://github.com/CodeForPhilly/ops/issues/new?assignees=&labels=repository&template=repository.md&title=Repo+for+%5BPROJECT%5D)


## ops-console

This repository includes a standard shell environment for linux
which includes all tooling needed to utilize the resources provided
in this repo.

### Requirements

* Linux OS
* Sudo/root access
* Bash
* [Habitat](https://www.habitat.sh/docs/install-habitat/)

### Installation

```
./script/bootstrap
```

To update to the latest version:

```
./script/update
```

### Running

```
./script/console
```
