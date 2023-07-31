output "www_lb_ip" {
  value = azurerm_public_ip.www_lb.ip_address
}

output "www_ip" {
  value = azurerm_network_interface.www[*].ip_configuration[0].private_ip_address
}

output "ftd_ip" {
  value = azurerm_network_interface.fw_management[*].ip_configuration[0].private_ip_address
}

output "ftd_nlb_ip" {
  value = azurerm_network_interface.fw_nlb_management[*].ip_configuration[0].private_ip_address
}

output "fmc_ip" {
  value = azurerm_network_interface.fmc_management.ip_configuration[0].private_ip_address
}

output "mgm_ip" {
  value = azurerm_public_ip.mgm.ip_address
}

output "public_server_ip" {
  value = azurerm_public_ip.public_server.ip_address
}

output "gateways" {
  value = {
    inside = cidrhost(azurerm_subnet.fw_inside.address_prefixes[0], 1)
    outside = cidrhost(azurerm_subnet.fw_outside.address_prefixes[0], 1)
    data = cidrhost(azurerm_subnet.fw_data.address_prefixes[0], 1)

  }
}