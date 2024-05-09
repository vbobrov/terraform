resource "google_compute_network" "firewall" {
  for_each = toset(var.subnets)
  name                    = "firewall-${each.key}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "firewall" {
  count = length(local.all_subnets)
  name          = "firewall-${local.all_subnets[count.index][1]}-${local.all_subnets[count.index][0]}"
  ip_cidr_range = cidrsubnet(var.cidr,8,count.index)
  region        = local.all_subnets[count.index][0]
  network       = google_compute_network.firewall[local.all_subnets[count.index][1]].id
}
