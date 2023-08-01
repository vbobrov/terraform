
# VNET for standalone servers
resource "azurerm_virtual_network" "servers" {
  name                = "servers-net"
  address_space       = ["10.2.0.0/16"]
  resource_group_name = azurerm_resource_group.gwlb.name
  location            = azurerm_resource_group.gwlb.location
}

# Public Servers subnet
resource "azurerm_subnet" "public_servers" {
  name                 = "public-server-subnet"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.servers.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.servers.address_space[0], 8, 1)]
}

# Private Servers subnet
resource "azurerm_subnet" "private_servers" {
  name                 = "private-server-subnet"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.servers.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.servers.address_space[0], 8, 2)]
}