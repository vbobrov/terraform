# Provisions FTD firewalls in Firewall VPC
# Multiple firewalls are provisioned in each firewall AZ based on the count set in variables
data "aws_ami" "ftdv_7_3" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name   = "name"
    values = ["ftdv-7.3*"]
  }
  filter {
    name   = "product-code"
    values = ["a8sxy6easi2zumgtyr564z6y7"]
  }
}

# Management interfaces
resource "aws_network_interface" "ftd_management" {
  count           = local.fw_az_count * var.fw_per_az
  description     = "ftd_management_if-${count.index + 1}"
  subnet_id       = aws_subnet.fw_management[floor(count.index / var.fw_per_az)].id
  security_groups = [aws_security_group.all_access.id]
  tags = {
    Name    = "ftd_management_if-${count.index + 1}"
    Project = "gwlb"
  }
}

# Diagnostic interfaces
resource "aws_network_interface" "ftd_diagnostic" {
  count           = local.fw_az_count * var.fw_per_az
  description     = "ftd_diagnstic_if-${count.index + 1}"
  subnet_id       = aws_subnet.fw_management[floor(count.index / var.fw_per_az)].id
  security_groups = [aws_security_group.all_access.id]
  tags = {
    Name    = "ftd_diagnostic_if-${count.index + 1}"
    Project = "gwlb"
  }
}

# Data interfaces
resource "aws_network_interface" "ftd_data" {
  count             = local.fw_az_count * var.fw_per_az
  description       = "ftd_data_if-${count.index + 1}"
  subnet_id         = aws_subnet.fw_data[floor(count.index / var.fw_per_az)].id
  security_groups   = [aws_security_group.all_access.id]
  source_dest_check = false
  tags = {
    Name    = "ftd_data_if-${count.index + 1}"
    Project = "gwlb"
  }
}

# CCL interfaces
resource "aws_network_interface" "ftd_ccl" {
  count             = local.fw_az_count * var.fw_per_az
  description       = "ftd_ccl_if-${count.index + 1}"
  subnet_id         = aws_subnet.fw_ccl[floor(count.index / var.fw_per_az)].id
  security_groups   = [aws_security_group.all_access.id]
  source_dest_check = false
  tags = {
    Name    = "ftd_ccl_if-${count.index + 1}"
    Project = "gwlb"
  }
}

# FTD Firewalls
resource "aws_instance" "ftd" {
  count                       = local.fw_az_count * var.fw_per_az
  ami                         = data.aws_ami.ftdv_7_3.id
  instance_type               = "c5.xlarge"
  key_name                    = var.ssh_key
  user_data_replace_on_change = true
  user_data                   = <<-EOT
  {
    "AdminPassword": "Cisco123!",
    "Hostname": "ftd-${count.index + 1}",
    "FirewallMode": "Routed",
    "ManageLocally": "No",
    "Cluster": {
      "CclSubnetRange": "${cidrhost(cidrsubnet(aws_vpc.fw.cidr_block, 8, 16), 1 + 16 * floor(count.index / var.fw_per_az))} ${cidrhost(cidrsubnet(aws_vpc.fw.cidr_block, 8, 16), 14 + 16 * floor(count.index / var.fw_per_az))}",
      "ClusterGroupName": "${var.cluster_prefix}-${floor(count.index / var.fw_per_az) + 1}",
      "Geneve": "Yes",
      "HealthProbePort": "12345"
    }
  }
  EOT

  network_interface {
    network_interface_id = aws_network_interface.ftd_management[count.index].id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.ftd_diagnostic[count.index].id
    device_index         = 1
  }
  network_interface {
    network_interface_id = aws_network_interface.ftd_data[count.index].id
    device_index         = 2
  }
  network_interface {
    network_interface_id = aws_network_interface.ftd_ccl[count.index].id
    device_index         = 3
  }
  tags = {
    Name    = "ftd_${count.index + 1}"
    Project = "gwlb"
  }
}