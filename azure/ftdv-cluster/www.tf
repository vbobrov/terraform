resource "azurerm_network_interface" "www" {
  count               = var.www_zones * var.www_per_zone
  name                = "www-nic-${count.index + 1}"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "www-nic-ip-${count.index + 1}"
    subnet_id                     = azurerm_subnet.www.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "www" {
  count                           = var.www_zones * var.www_per_zone
  name                            = "www-${count.index + 1}"
  computer_name                   = "www-${count.index + 1}"
  location                        = azurerm_resource_group.gwlb.location
  zone                            = tostring(floor(count.index / var.www_per_zone) + 1)
  resource_group_name             = azurerm_resource_group.gwlb.name
  network_interface_ids           = [azurerm_network_interface.www[count.index].id]
  size                            = "Standard_B1s"
  admin_username                  = "azadmin"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  user_data = base64encode(<<-EOT
    #!/bin/bash
    apt update
    apt upgrade
    apt install -y apache2
    echo "<h1>www-${count.index + 1}</h1>" >/var/www/html/index.html
  EOT
  )

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy-daily"
    sku       = "22_04-daily-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "www-os-disk-${count.index + 1}"
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