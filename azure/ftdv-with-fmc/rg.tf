# Resource group for the project
resource "azurerm_resource_group" "gwlb" {
  name     = "gwlb-rg"
  location = var.location
}

# Storange account for Boot Diagnostics. This is needed to connect to the console of VMs
resource "azurerm_storage_account" "diag" {
  name                     = "gwlbdiag"
  resource_group_name      = azurerm_resource_group.gwlb.name
  location                 = azurerm_resource_group.gwlb.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}