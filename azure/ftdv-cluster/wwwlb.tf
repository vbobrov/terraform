resource "azurerm_public_ip" "www_lb" {
  name                = "www-ip"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "www_outbound" {
  name                = "www-outbound"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "www" {
  name                = "www-lb"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "www-lb-ip"
    public_ip_address_id = azurerm_public_ip.www_lb.id
    gateway_load_balancer_frontend_ip_configuration_id = azurerm_lb.fw.frontend_ip_configuration[0].id
  }

  frontend_ip_configuration {
    name                 = "www-outbound"
    public_ip_address_id = azurerm_public_ip.www_outbound.id
  }
}

resource "azurerm_lb_backend_address_pool" "www" {
  loadbalancer_id = azurerm_lb.www.id
  name            = "www-servers"
}

resource "azurerm_lb_backend_address_pool_address" "www" {
  count                   = var.www_zones * var.www_per_zone
  name                    = "www-lb-pool-${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.www.id
  virtual_network_id      = azurerm_virtual_network.www.id
  ip_address              = azurerm_network_interface.www[count.index].ip_configuration[0].private_ip_address
}

resource "azurerm_lb_probe" "http_probe" {
  loadbalancer_id = azurerm_lb.www.id
  name            = "http-probe"
  protocol        = "Http"
  request_path    = "/"
  port            = 80
}

resource "azurerm_lb_rule" "www" {
  loadbalancer_id                = azurerm_lb.www.id
  name                           = "HTTP"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "www-lb-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.www.id]
  probe_id                       = azurerm_lb_probe.http_probe.id
  disable_outbound_snat = true
}

resource "azurerm_lb_outbound_rule" "www" {
  name                    = "www-outbound"
  loadbalancer_id         = azurerm_lb.www.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.www.id
  allocated_outbound_ports =512

  frontend_ip_configuration {
    name = "www-outbound"
  }
}

resource "azurerm_dns_a_record" "www" {
  name                = "www"
  zone_name           = "az.ciscodemo.net"
  resource_group_name = "dns"
  ttl                 = 5
  records             = [azurerm_public_ip.www_lb.ip_address]
}
