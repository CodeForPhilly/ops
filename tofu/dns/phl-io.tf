# phl.io — hosts the live cluster's *.live.k8s.phl.io namespace plus a few
# apex-style service names that CNAME into it.

locals {
  phl_io_zone = "phl-io"
}

# Per-host overrides of the wildcard below. See locals.tf for the host->LB map.
resource "google_dns_record_set" "live_k8s_host" {
  for_each = local.live_k8s_hosts

  managed_zone = local.phl_io_zone
  name         = "${each.key}.live.k8s.phl.io."
  type         = "A"
  ttl          = 60
  rrdatas      = [local.lb[each.value]]
}

# Catch-all for every *.live.k8s.phl.io name without a specific record above.
#
# Now on Envoy. Every app in the cluster has a Gateway + HTTPRoute, so there is
# nothing left for this to strand — the reason it was held back is gone.
#
# The per-host records in live_k8s_host are now redundant (they resolve to the
# same IP this does) and are removed in a follow-up, separately: destroying them
# in the same apply that flips this record risks a destroy landing first and
# dropping that host onto nginx for a few seconds.
resource "google_dns_record_set" "live_k8s_wildcard" {
  managed_zone = local.phl_io_zone
  name         = "*.live.k8s.phl.io."
  type         = "A"
  ttl          = 300
  rrdatas      = [local.lb["envoy"]]
}

# Service names that resolve into the cluster via the records above. Pointing
# them at a *.live.k8s.phl.io target rather than an IP means they follow their
# app's cutover automatically.
resource "google_dns_record_set" "vaultwarden" {
  managed_zone = local.phl_io_zone
  name         = "vaultwarden.phl.io."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["vaultwarden.live.k8s.phl.io."]
}

resource "google_dns_record_set" "bitwarden" {
  managed_zone = local.phl_io_zone
  name         = "bitwarden.phl.io."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["vaultwarden.phl.io."]
}

resource "google_dns_record_set" "penn_chime" {
  managed_zone = local.phl_io_zone
  name         = "penn-chime.phl.io."
  type         = "CNAME"
  ttl          = 10
  rrdatas      = ["penn-chime.live.k8s.phl.io."]
}
