# FTD Management Interfaces
resource "azurerm_network_interface" "fw_management" {
  count               = var.fw_zones * var.fw_per_zone
  name                = "fw-management-nic-${count.index + 1}"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fw-management-nic-ip-${count.index + 1}"
    subnet_id                     = azurerm_subnet.fw_management.id
    private_ip_address_allocation = "Dynamic"
  }
}

# FTD Diag Interfaces
resource "azurerm_network_interface" "fw_diagnostic" {
  count               = var.fw_zones * var.fw_per_zone
  name                = "fw-diagnostic-nic-${count.index + 1}"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fw-diagnostic-nic-ip-${count.index + 1}"
    subnet_id                     = azurerm_subnet.fw_management.id
    private_ip_address_allocation = "Dynamic"
  }
}

# FTD Data Interfaces (VXLAN)
resource "azurerm_network_interface" "fw_data" {
  count                = var.fw_zones * var.fw_per_zone
  name                 = "fw-data-nic-${count.index + 1}"
  location             = azurerm_resource_group.gwlb.location
  resource_group_name  = azurerm_resource_group.gwlb.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "fw-data-nic-ip-${count.index + 1}"
    subnet_id                     = azurerm_subnet.fw_data.id
    private_ip_address_allocation = "Dynamic"
  }
}

# FTD Cluster Control Interfaces
resource "azurerm_network_interface" "fw_ccl" {
  count               = var.fw_zones * var.fw_per_zone
  name                = "fw-ccl-nic-${count.index + 1}"
  location            = azurerm_resource_group.gwlb.location
  resource_group_name = azurerm_resource_group.gwlb.name

  ip_configuration {
    name                          = "fw-cl-nic-ip-${count.index + 1}"
    subnet_id                     = azurerm_subnet.fw_ccl.id
    private_ip_address_allocation = "Dynamic"
  }
}

# FTD VMs
resource "azurerm_linux_virtual_machine" "ftd" {
  count               = var.fw_zones * var.fw_per_zone
  name                = "ftd-${count.index + 1}"
  computer_name       = "ftd-${count.index + 1}"
  location            = azurerm_resource_group.gwlb.location
  zone                = tostring(floor(count.index / var.fw_per_zone) + 1)
  resource_group_name = azurerm_resource_group.gwlb.name
  network_interface_ids = [
    azurerm_network_interface.fw_management[count.index].id,
    azurerm_network_interface.fw_diagnostic[count.index].id,
    azurerm_network_interface.fw_data[count.index].id,
    azurerm_network_interface.fw_ccl[count.index].id
  ]
  size                            = "Standard_D3_v2"
  admin_username                  = "azadmin"
  admin_password                  = var.admin_password
  disable_password_authentication = false

  custom_data = base64encode(jsonencode(
    {
      "AdminPassword" : var.admin_password,
      "Hostname" : "ftd-${count.index + 1}",
      "FirewallMode" : "Routed",
      "ManageLocally" : "No",
      # "Cluster" : {
      #   # CCL Range is calculated based on fw_ccl subnet from IP address .1 to .8
      #   "CclSubnetRange" : "${cidrhost(azurerm_subnet.fw_ccl.address_prefixes[0], 1)} ${cidrhost(azurerm_subnet.fw_ccl.address_prefixes[0], 8)}",
      #   "ClusterGroupName" : "${var.cluster_prefix}-1",
      #   "HealthProbePort" : "${var.health_port}",
      #   "GatewayLoadBalancerIP" : "${azurerm_lb.fw.frontend_ip_configuration[0].private_ip_address}",
      #   "EncapsulationType" : "vxlan",
      #   # These values must match the backend pool of GWLB
      #   "InternalPort" : "10800",
      #   "ExternalPort" : "10801",
      #   "InternalSegId" : "800",
      #   "ExternalSegId" : "801"
      # }
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
    name                 = "fw-os-disk-${count.index + 1}"
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