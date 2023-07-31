# FW Internal Load Balancer.
resource "azurerm_lb" "fw_ilb" {
  name                = "fw-ilb"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name      = "fw-ilb-ip"
    subnet_id = azurerm_subnet.fw_inside.id
  }
}

# FW Internal backend pool
resource "azurerm_lb_backend_address_pool" "fw_ilb" {
  loadbalancer_id = azurerm_lb.fw_ilb.id
  name            = "fw_ilb_pool"
}

# FW Inside NIC IP association to backend pool
resource "azurerm_network_interface_backend_address_pool_association" "fw_ilb" {
  count                   = var.fw_zones * var.fw_per_zone
  network_interface_id    = azurerm_network_interface.fw_nlb_inside[count.index].id
  ip_configuration_name   = "fw-nlb-inside-nic-ip-${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.fw_ilb.id
}

# Health Probe
resource "azurerm_lb_probe" "fw_ilb" {
  loadbalancer_id = azurerm_lb.fw_ilb.id
  name            = "tcp-${var.health_port}"
  protocol        = "Tcp"
  port            = var.health_port
}

# Inside LB Rule
resource "azurerm_lb_rule" "inside" {
  loadbalancer_id                = azurerm_lb.fw_ilb.id
  name                           = "All-Traffic"
  protocol                       = "All"
  frontend_ip_configuration_name = "fw-ilb-ip"
  frontend_port                  = 0
  backend_port                   = 0
  load_distribution              = "SourceIP"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.fw_ilb.id]
  probe_id                       = azurerm_lb_probe.fw_ilb.id
}

# FW External Load Balancer Public IP
resource "azurerm_public_ip" "fw_elb" {
  name                = "fw-elb-ip"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "fw_elb" {
  name                = "fw-elb"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                                               = "fw-elb-ip"
    public_ip_address_id                               = azurerm_public_ip.fw_elb.id
  }
}

# ELB backend pool
resource "azurerm_lb_backend_address_pool" "fw_elb" {
  loadbalancer_id = azurerm_lb.fw_elb.id
  name            = "fw-elb"
}

# ELB NIC IP association to backend pool
resource "azurerm_network_interface_backend_address_pool_association" "fw_elb" {
  count                   = var.fw_zones * var.fw_per_zone
  network_interface_id    = azurerm_network_interface.fw_nlb_outside[count.index].id
  ip_configuration_name   = "fw-nlb-outside-nic-ip-${count.index + 1}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.fw_elb.id
}

# Health Probe
resource "azurerm_lb_probe" "fw_elb" {
  loadbalancer_id = azurerm_lb.fw_elb.id
  name            = "tcp-${var.health_port}"
  protocol        = "Tcp"
  port            = var.health_port
}

# Outbound ELB Rule
resource "azurerm_lb_outbound_rule" "fw_elb" {
  name                     = "fw-elb-outbound"
  loadbalancer_id          = azurerm_lb.fw_elb.id
  protocol                 = "All"
  backend_address_pool_id  = azurerm_lb_backend_address_pool.fw_elb.id
  allocated_outbound_ports = 512

  frontend_ip_configuration {
    name = "fw-elb-ip"
  }
}

