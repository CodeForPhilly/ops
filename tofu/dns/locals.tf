locals {
  # Load balancers fronting the live LKE cluster (lke17521).
  #
  # ingress-nginx is being decommissioned (CodeForPhilly/cfp-live-cluster#144).
  # It requires PROXY protocol on every connection, which only the Linode
  # NodeBalancer supplies — so nothing inside the cluster can reach it, and
  # cert-manager's mandatory HTTP-01 self-check fails against it. Certificates
  # can therefore no longer be issued through nginx at all. Every hostname must
  # reach Envoy before its cert can renew.
  lb = {
    envoy = "45.79.246.168"
    nginx = "104.237.148.175"
  }

  # Which load balancer each *.live.k8s.phl.io hostname resolves to.
  #
  # Each entry is a specific A record that overrides the *.live.k8s.phl.io
  # wildcard for that one name. Flipping a host from "nginx" to "envoy" here IS
  # the phase-4 DNS cutover for that host: apply, and cert-manager issues its
  # Gateway cert within a few minutes.
  #
  # Before flipping one, confirm the app's Gateway + HTTPRoute exist in
  # cfp-live-cluster and that the ACME solver already answers through Envoy.
  live_k8s_hosts = {
    "echo-http"            = "envoy"
    "metrics"              = "envoy"
    "codeforphilly"        = "envoy"
    "vaultwarden"          = "envoy"
    "penn-chime"           = "envoy"
    "sealed-secrets"       = "envoy"
    "choose-native-plants" = "envoy"

    # Still on nginx. Their certs are valid but CANNOT renew — cut over before
    # they expire, or these hosts go dark.
    "third-places"       = "nginx" # cert expires 2026-07-22
    "browserless-chrome" = "nginx" # cert expires 2026-08-07
  }
}
