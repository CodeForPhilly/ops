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
