# codeforphilly.org — the main public site, served from the code-for-philly
# namespace in the live cluster.

locals {
  codeforphilly_zone = "codeforphilly"
}

resource "google_dns_record_set" "codeforphilly_apex" {
  managed_zone = local.codeforphilly_zone
  name         = "codeforphilly.org."
  type         = "A"
  ttl          = 60
  rrdatas      = [local.lb["envoy"]]
}

# Catch-all for subdomains without an explicit record (notably www).
# It resolves to the apex, so www follows the apex's cutover for free —
# there is no separate www record to keep in sync.
resource "google_dns_record_set" "codeforphilly_wildcard" {
  managed_zone = local.codeforphilly_zone
  name         = "*.codeforphilly.org."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["codeforphilly.org."]
}

# Explicit subdomains that override the wildcard. Both existed in the zone
# before this stack managed them; the import blocks below adopt them.

# next.codeforphilly.org — pre-cutover home of the codeforphilly.org rewrite
# (cfp-live-cluster, namespace codeforphilly-ng). CNAME to the apex so it
# reaches the live Envoy gateway and follows the apex, like the wildcard.
# Previously a CNAME to codeforphilly.github.io.
resource "google_dns_record_set" "codeforphilly_next" {
  managed_zone = local.codeforphilly_zone
  name         = "next.codeforphilly.org."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["codeforphilly.org."]
}

# next-v2.codeforphilly.org — the rewrite's sandbox deployment
# (cfp-sandbox-cluster). Unchanged; adopted so every explicit record in the
# zone is managed here.
resource "google_dns_record_set" "codeforphilly_next_v2" {
  managed_zone = local.codeforphilly_zone
  name         = "next-v2.codeforphilly.org."
  type         = "CNAME"
  ttl          = 300
  rrdatas      = ["sandbox.k8s.phl.io."]
}

