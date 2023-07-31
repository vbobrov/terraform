# FMC Management Interface
resource "azurerm_network_interface" "fmc_management" {
  name                = "fmc-management-nic"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fmc-management-nic-ip"
    subnet_id                     = azurerm_subnet.fmc.id
    private_ip_address_allocation = "Dynamic"
  }
}

# FMC VM
resource "azurerm_linux_virtual_machine" "fmc" {
  name                = "fmc"
  computer_name       = "fmc"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  network_interface_ids = [
    azurerm_network_interface.fmc_management.id,
  ]
  size                            = "Standard_D4_v2"
  admin_username                  = "azadmin"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  custom_data = base64encode(
    jsonencode(
      {
        "AdminPassword" : var.admin_password,
        "Hostname" : "fmc",
      }
    )
  )

  source_image_reference {
    publisher = "cisco"
    offer     = "cisco-fmcv"
    sku       = "fmcv-azure-byol"
    version   = "73069.0.0"
  }

  plan {
    publisher = "cisco"
    product   = "cisco-fmcv"
    name      = "fmcv-azure-byol"
  }

  os_disk {
    name                 = "fmc-os-disk"
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