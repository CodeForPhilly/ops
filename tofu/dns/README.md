# dns

Cloud DNS records for Code for Philly, in the `openphl-1177` GCP project.

Two zones are managed here:

| Zone | Managed zone name |
| --- | --- |
| `phl.io` | `phl-io` |
| `codeforphilly.org` | `codeforphilly` |

**Only records that route into the live Kubernetes cluster are managed.** The zones
contain many other records (Google Workspace, Mailgun, Discourse, …) that are not in
state and are left alone — OpenTofu only touches what it declares.

`choosenativeplants.com` is registered at **Namecheap**, not Cloud DNS, so it can't be
managed here. It has to be edited by hand until the zone moves.

## Cutting a hostname over to Envoy

The live cluster is migrating from ingress-nginx to Envoy Gateway
([cfp-live-cluster#144](https://github.com/CodeForPhilly/cfp-live-cluster/issues/144)).
`locals.tf` holds a map of each `*.live.k8s.phl.io` hostname to the load balancer it
resolves to. **Flipping one entry from `nginx` to `envoy` is the DNS cutover.**

```hcl
live_k8s_hosts = {
  "third-places" = "envoy"   # was "nginx"
}
```

Before you flip one, confirm in the cluster that the app's Gateway and HTTPRoute exist
and that the ACME solver already answers through Envoy:

```bash
export KUBECONFIG=~/.kube/cfp-live-cluster-kubeconfig.yaml
CH=$(kubectl -n <app> get challenges -o json \
  | jq -r '.items[] | select(.spec.solver.http01.gatewayHTTPRoute) | .metadata.name' | head -1)
TOKEN=$(kubectl -n <app> get challenge "$CH" -o jsonpath='{.spec.token}')
KEY=$(kubectl -n <app> get challenge "$CH" -o jsonpath='{.spec.key}')
curl -s --resolve <host>:80:45.79.246.168 \
  "http://<host>/.well-known/acme-challenge/$TOKEN"
# must print exactly $KEY
```

If that prints the key, `tofu apply` and the certificate issues within a few minutes.

Expect the host to be **hard-down for roughly 60–90 seconds** between the DNS change and
the certificate landing: Envoy 301s HTTP to HTTPS, and its HTTPS listener does not
program until the cert Secret exists. TTLs are 60s, so deleting the record rolls back
almost immediately.

## Why certs can only issue through Envoy

ingress-nginx is configured with `use-proxy-protocol: true` and the Linode annotation
`linode-loadbalancer-proxy-protocol: v2`. It requires a PROXY header on every
connection, and only the Linode NodeBalancer adds one. Traffic originating *inside* the
cluster is short-circuited straight to the nginx pods by kube-proxy, never traverses the
NodeBalancer, arrives with no PROXY header, and gets dropped.

cert-manager must pass its own in-cluster HTTP-01 self-check before it will ask Let's
Encrypt to validate. That self-check cannot succeed against nginx. **No certificate has
issued through nginx since hairpin-proxy was removed on 2026-05-18**, which is what
expired nine certificates simultaneously on 2026-07-12. Envoy does not use proxy
protocol, so it is reachable in-cluster and its self-checks pass.

The practical consequence: a hostname still pointed at nginx **cannot renew its
certificate**. Every remaining host must be cut over before its current cert expires.

## The wildcard

`*.live.k8s.phl.io` still points at nginx, and each migrated host gets a specific A
record overriding it. Once every host in `live_k8s_hosts` is on `envoy`, repoint the
wildcard at Envoy and delete the per-host records.

Do **not** flip the wildcard early as a shortcut — it moves every hostname at once,
including any whose Gateway isn't ready, which is exactly how the sandbox migration
broke itself.
