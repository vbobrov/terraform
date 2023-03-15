output "www_lb_ip" {
  value = azurerm_public_ip.www_lb.ip_address
}

output "www_ip" {
  value = azurerm_network_interface.www[*].ip_configuration[0].private_ip_address
}

output "ftd_ip" {
  value = azurerm_network_interface.fw_management[*].ip_configuration[0].private_ip_address
}

output "mgm_ip" {
  value = azurerm_public_ip.mgm.ip_address
}