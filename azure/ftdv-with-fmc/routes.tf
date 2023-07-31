resource "azurerm_route_table" "ilb" {
  name                = "ilb-route-table"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
}


resource "azurerm_route" "ilb-default" {
  name                   = "default-via-ilb"
  resource_group_name    = azurerm_resource_group.gwlb.name
  route_table_name       = azurerm_route_table.ilb.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_lb.fw_ilb.frontend_ip_configuration[0].private_ip_address
}

resource "azurerm_subnet_route_table_association" "private_servers" {
  subnet_id      = azurerm_subnet.private_servers.id
  route_table_id = azurerm_route_table.ilb.id
}