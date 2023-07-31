# FTD Management Interfaces
resource "azurerm_network_interface" "fw_nlb_management" {
  count               = var.fw_zones * var.fw_per_zone
  name                = "fw-nlb-management-nic-${count.index + 1}"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fw-nlb-management-nic-ip-${count.index + 1}"
    subnet_id                     = azurerm_subnet.fw_management.id
    private_ip_address_allocation = "Dynamic"
  }
}

# FTD Diag Interfaces
resource "azurerm_network_interface" "fw_nlb_diagnostic" {
  count               = var.fw_zones * var.fw_per_zone
  name                = "fw-nlb-diagnostic-nic-${count.index + 1}"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fw-nlb-diagnostic-nic-ip-${count.index + 1}"
    subnet_id                     = azurerm_subnet.fw_management.id
    private_ip_address_allocation = "Dynamic"
  }
}

# FTD Inside Interfaces
resource "azurerm_network_interface" "fw_nlb_inside" {
  count               = var.fw_zones * var.fw_per_zone
  name                = "fw-nlb-inside-nic-${count.index + 1}"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "fw-nlb-inside-nic-ip-${count.index + 1}"
    subnet_id                     = azurerm_subnet.fw_inside.id
    private_ip_address_allocation = "Dynamic"
  }
}

# FTD Outside Interfaces
resource "azurerm_network_interface" "fw_nlb_outside" {
  count               = var.fw_zones * var.fw_per_zone
  name                = "fw-nlb-outside-nic-${count.index + 1}"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fw-nlb-outside-nic-ip-${count.index + 1}"
    subnet_id                     = azurerm_subnet.fw_outside.id
    private_ip_address_allocation = "Dynamic"
  }
}

# FTD VMs
resource "azurerm_linux_virtual_machine" "ftd_nlb" {
  count               = var.fw_zones * var.fw_per_zone
  name                = "ftd-nlb-${count.index + 1}"
  computer_name       = "ftd-nlb-${count.index + 1}"
  location            = azurerm_resource_group.gwlb.location
  zone                = tostring(floor(count.index / var.fw_per_zone) + 1)
  resource_group_name = azurerm_resource_group.gwlb.name
  network_interface_ids = [
    azurerm_network_interface.fw_nlb_management[count.index].id,
    azurerm_network_interface.fw_nlb_diagnostic[count.index].id,
    azurerm_network_interface.fw_nlb_outside[count.index].id,
    azurerm_network_interface.fw_nlb_inside[count.index].id
  ]
  size                            = "Standard_D3_v2"
  admin_username                  = "azadmin"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  custom_data = base64encode(jsonencode(
    {
      "AdminPassword" : var.admin_password,
      "Hostname" : "ftd-nlb-${count.index + 1}",
      "FirewallMode" : "Routed",
      "ManageLocally" : "No",
    }
    )
  )

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-ftdv"
    sku       = "ftdv-azure-byol"
    version   = "73069.0.0"
  }

  plan {
    publisher = "cisco"
    product   = "cisco-ftdv"
    name      = "ftdv-azure-byol"
  }

  os_disk {
    name                 = "fw-nlb-os-disk-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "azadmin"
    public_key = file("~/.ssh/aws-ssh-1.pub")
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diag.primary_blob_endpoint
  }
}