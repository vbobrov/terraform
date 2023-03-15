resource "azurerm_virtual_network" "gwlb" {
  name                = "gwlb-net"
  address_space       = ["10.100.0.0/16"]
  resource_group_name = azurerm_resource_group.gwlb.name
  location            = azurerm_resource_group.gwlb.location
}

resource "azurerm_subnet" "fw_management" {
  name                 = "fw-management"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.gwlb.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.gwlb.address_space[0], 8, 1)]
}

resource "azurerm_subnet" "fw_data" {
  name                 = "fw-data"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.gwlb.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.gwlb.address_space[0], 8, 2)]
}

resource "azurerm_subnet" "fw_ccl" {
  name                 = "fw-ccl"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.gwlb.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.gwlb.address_space[0], 8, 3)]
}

resource "azurerm_network_security_group" "fw" {
  name                = "fw-nsg"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  security_rule {
    name                       = "All-Inbound"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "All-Outbound"
    priority                   = 1001
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "www" {
  name                = "www-net"
  address_space       = ["10.1.0.0/16"]
  resource_group_name = azurerm_resource_group.gwlb.name
  location            = azurerm_resource_group.gwlb.location
}

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

resource "azurerm_subnet" "www" {
  name                 = "www-subnet"
  resource_group_name  = azurerm_resource_group.gwlb.name
  virtual_network_name = azurerm_virtual_network.www.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.www.address_space[0], 8, 1)]
}

resource "azurerm_subnet_network_security_group_association" "www" {
  subnet_id                 = azurerm_subnet.www.id
  network_security_group_id = azurerm_network_security_group.www.id
}
