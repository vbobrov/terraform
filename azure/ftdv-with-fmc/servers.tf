# Public IP address for jump host
resource "azurerm_public_ip" "public_server" {
  name                = "public-server-ip"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

# NSG association with Server NIC
resource "azurerm_network_interface_security_group_association" "public_server" {
  network_interface_id      = azurerm_network_interface.public_server.id
  network_security_group_id = azurerm_network_security_group.www.id
}

# Public Server NIC
resource "azurerm_network_interface" "public_server" {
  name                = "public-server-nic"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "public-server-nic-ip"
    subnet_id                     = azurerm_subnet.public_servers.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_server.id
  }
}

# Public Server VM
resource "azurerm_linux_virtual_machine" "public_server" {
  name                            = "public-server"
  computer_name                   = "public-server"
  location                        = azurerm_resource_group.gwlb.location
  resource_group_name             = azurerm_resource_group.gwlb.name
  network_interface_ids           = [azurerm_network_interface.public_server.id]
  size                            = "Standard_B1s"
  admin_username                  = "azadmin"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  user_data = base64encode(<<-EOT
    #!/bin/bash
    apt update -y
    apt upgrade -y
    apt install -y apache2
    echo "<h1>Public Server</h1>" >/var/www/html/index.html
  EOT
  )

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy-daily"
    sku       = "22_04-daily-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "public-server-os-disk"
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


# Private Server NIC
resource "azurerm_network_interface" "private_server" {
  name                = "private-server-nic"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "private-server-nic-ip"
    subnet_id                     = azurerm_subnet.private_servers.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Private Server VM
resource "azurerm_linux_virtual_machine" "private_server" {
  name                            = "private-server"
  computer_name                   = "private-server"
  location                        = azurerm_resource_group.gwlb.location
  resource_group_name             = azurerm_resource_group.gwlb.name
  network_interface_ids           = [azurerm_network_interface.private_server.id]
  size                            = "Standard_B1s"
  admin_username                  = "azadmin"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy-daily"
    sku       = "22_04-daily-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "private-server-os-disk"
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
