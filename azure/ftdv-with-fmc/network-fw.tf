# VNET for firewalls
resource "azurerm_virtual_network" "gwlb" {
  name                = "gwlb-net"
  address_space       = [var.fw_cidr]
  resource_group_name = azurerm_resource_group.gwlb.name
  location            = azurerm_resource_group.gwlb.location
}

# Management subnet
resource "azurerm_subnet" "fw_management" {
  name                 = "fw-management"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.gwlb.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.gwlb.address_space[0], 4, 1)]
}

# Data subnet
resource "azurerm_subnet" "fw_data" {
  name                 = "fw-data"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.gwlb.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.gwlb.address_space[0], 4, 2)]
}

# CCL subnet
resource "azurerm_subnet" "fw_ccl" {
  name                 = "fw-ccl"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.gwlb.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.gwlb.address_space[0], 4, 3)]
}

# Inside subnet
resource "azurerm_subnet" "fw_inside" {
  name                 = "fw-inside"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.gwlb.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.gwlb.address_space[0], 4, 5)]
}

# Outside subnet
resource "azurerm_subnet" "fw_outside" {
  name                 = "fw-outside"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.gwlb.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.gwlb.address_space[0], 4, 6)]
}

# FMC subnet
resource "azurerm_subnet" "fmc" {
  name                 = "fmc"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.gwlb.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.gwlb.address_space[0], 4, 4)]
}

# NSG for jump host
resource "azurerm_network_security_group" "mgm" {
  name                = "mgm-nsg"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  dynamic "security_rule" {
    for_each = { for s in range(length(var.ssh_sources)) : tostring(1001 + s) => var.ssh_sources[s] }
    content {
      name                       = "SSH_${security_rule.key}"
      priority                   = security_rule.key
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = security_rule.value
      destination_address_prefix = "*"
    }
  }
}
