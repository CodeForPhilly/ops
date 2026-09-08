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

  # Per-host A records overriding the *.live.k8s.phl.io wildcard.
  #
  # These exist only to peel hostnames off nginx one at a time while the
  # wildcard stayed put. The wildcard now points at Envoy, so every entry here
  # resolves to the same IP it would without a record — they are vestigial, and
  # are removed in a follow-up once the wildcard flip is confirmed live.
  #
  # A host absent from this map simply follows the wildcard. That is why
  # third-places and browserless-chrome are NOT listed: the wildcard cuts them
  # over for free, and inventing a record just to delete it later is churn.
  #
  # Do not add to this map. A new host needs no record.
  live_k8s_hosts = {
    "echo-http"            = "envoy"
    "metrics"              = "envoy"
    "codeforphilly"        = "envoy"
    "vaultwarden"          = "envoy"
    "penn-chime"           = "envoy"
    "sealed-secrets"       = "envoy"
    "choose-native-plants" = "envoy"
  }
}
