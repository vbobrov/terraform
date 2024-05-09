data "google_compute_image" "ftd" {
  project = "cisco-public"
  name    = var.ftd_image
}

resource "google_compute_instance" "ftd" {
  for_each = var.ftd_config
  name                    = each.key
  metadata_startup_script = jsonencode({
    AdminPassword: var.admin_password,
    Hostname: each.key,
    ManageLocally: "No"
    FmcIp: var.fmc_ip
    FmcRegKey: var.fmc_key
  })

  machine_type            = var.machine_type
  zone                    = "${var.region}-${each.value["zone"]}"
  can_ip_forward          = true
  boot_disk {
    initialize_params {
      image = data.google_compute_image.ftd.self_link
    }
  }
  metadata = {
    serial-port-enable = true
  }

  dynamic "network_interface" {
    for_each = var.subnets
    content {
      network = data.google_compute_subnetwork.firewall[network_interface.value].network
      subnetwork = data.google_compute_subnetwork.firewall[network_interface.value].self_link
    }
    
  }
  lifecycle {
    ignore_changes = [metadata["ssh-keys"]]
  }
}