# VNET for WWW servers
resource "azurerm_virtual_network" "www" {
  name                = "www-net"
  address_space       = ["10.1.0.0/16"]
  resource_group_name = azurerm_resource_group.gwlb.name
  location            = azurerm_resource_group.gwlb.location
}

# WWW subnet
resource "azurerm_subnet" "www" {
  name                 = "www-subnet"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.www.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.www.address_space[0], 8, 1)]
}

# NSG for WWW Servers
resource "azurerm_network_security_group" "www" {
  name                = "www-nsg"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  security_rule {
    name                       = "HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# WWW NSG Association
resource "azurerm_subnet_network_security_group_association" "www" {
  subnet_id                 = azurerm_subnet.www.id
  network_security_group_id = azurerm_network_security_group.www.id
}
