resource "azurerm_lb" "fw" {
  name                = "fw-lb"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  sku                 = "Gateway"

  frontend_ip_configuration {
    name                 = "fw-lb-ip"
    subnet_id = azurerm_subnet.fw_data.id
  }
}

resource "azurerm_lb_backend_address_pool" "fw" {
  loadbalancer_id = azurerm_lb.fw.id
  name            = "firewalls"
  tunnel_interface {
    identifier = 800
    type = "Internal"
    protocol = "VXLAN"
    port = 10800
  }

  tunnel_interface {
    identifier = 801
    type = "External"
    protocol = "VXLAN"
    port = 10801
  }
}

resource "azurerm_lb_backend_address_pool_address" "fw" {
  count                   = var.fw_zones * var.fw_per_zone
  name                    = "fw-lb-pool-${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.fw.id
  virtual_network_id      = azurerm_virtual_network.gwlb.id
  ip_address              = azurerm_network_interface.fw_data[count.index].ip_configuration[0].private_ip_address
}

resource "azurerm_lb_probe" "tcp_12345" {
  loadbalancer_id = azurerm_lb.fw.id
  name            = "tcp-12345"
  protocol        = "Tcp"
  port            = 12345
}

resource "azurerm_lb_rule" "gwlb" {
  loadbalancer_id                = azurerm_lb.fw.id
  name                           = "All-Traffic"
  protocol = "All"
  frontend_ip_configuration_name = "fw-lb-ip"
  frontend_port = 0
  backend_port = 0
  load_distribution = "SourceIP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.fw.id]
  probe_id                       = azurerm_lb_probe.tcp_12345.id
}