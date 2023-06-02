# Public IP address for jump host
resource "azurerm_public_ip" "mgm" {
  name                = "mgm-ip"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name
  allocation_method   = "Static"
}

# NSG association with MGM NIC
resource "azurerm_network_interface_security_group_association" "mgm" {
  network_interface_id      = azurerm_network_interface.mgm.id
  network_security_group_id = azurerm_network_security_group.mgm.id
}

# Jump host NIC
resource "azurerm_network_interface" "mgm" {
  name                = "mgm-nic"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "mgm-nic-ip"
    subnet_id                     = azurerm_subnet.fw_management.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mgm.id
  }
}

# Ubuntu jump host using daily Ubuntu 22 image
resource "azurerm_linux_virtual_machine" "mgm" {
  name                            = "fw-mgm"
  location                        = azurerm_resource_group.gwlb.location
  resource_group_name             = azurerm_resource_group.gwlb.name
  network_interface_ids           = [azurerm_network_interface.mgm.id]
  size                            = "Standard_B1s"
  computer_name                   = "fw-mgm"
  admin_username                  = "azadmin"
  disable_password_authentication = true

  user_data = base64encode(<<-EOT
    #!/bin/bash
    apt update
    apt install -y sshpass
    apt install -y python3-pip
    pip3 install ansible
  EOT
  )

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy-daily"
    sku       = "22_04-daily-lts"
    version   = "latest"
  }

  os_disk {
    name                 = "mgm-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "azadmin"
    public_key = file("~/.ssh/aws-ssh-1.pub")
  }

  connection {
    type        = "ssh"
    user        = "azadmin"
    host        = azurerm_public_ip.mgm.ip_address
    private_key = file(var.ssh_file)
    agent       = false
  }

  provisioner "remote-exec" {
    inline = ["sudo cloud-init status --wait"]
  }

  provisioner "file" {
    source      = var.ssh_file
    destination = "/home/azadmin/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = ["chmod 400 /home/azadmin/.ssh/id_rsa"]
  }
}