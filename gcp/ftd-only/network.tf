data "google_compute_subnetwork" "firewall" {
  for_each = toset(var.subnets)
  name = each.key
  region = var.region
}
