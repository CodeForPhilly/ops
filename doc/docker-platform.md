# docker-platform

This document details the various components which
are used to implement a docker-compose based platform
upon which to run Code for Philly projects

## Ansible automations

Ansible is the heart of the platform control plane and
is used to onboard new infrastructure, deploy platform
components, and deploy projects. For more information,
see the [ansible directory documentation](./ansible.md)

## Platform components

The runnable system components which enable multi-project
environments are deployed as a single docker-compose
project to each node. This docker-compose project is
maintained in [docker/projects/platform](../docker/projects/platform).
Service configurations which need to be changed/managed
post-runtime are always stored in volumes, thereby allowing
a separate control plane process to manage them.

### http-router

The http-router is the edge layer on each node which
routes incoing requests to the appropriate project &
container. It relies on DNS as a service discovery
mechanism.

All haproxy configs are stored in /usr/local/etc/haproxy
which is mounted as a volume. backend configs are loaded
from the backends/ subdorectory of the volume. This is
where per-project backends should be configured. Each
backend configuration will need an appropriate `use_backend`
directive added to the frontend config in order to expose
the project publicly.

### static-http

The static-http service is a simple nginx server
for serving static files. Any volumes containing
static files should simply be attached under
/usr/share/nginx/html and have appropriate frontend
routes configured to reach them.
