# Provisions FTD firewall
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

# Management interface
resource "aws_network_interface" "ftd_management" {
  description     = "ftd-management"
  subnet_id       = aws_subnet.management.id
  security_groups = [aws_security_group.management_access.id]

  tags = merge(
    local.tags,
    {
      Name = "ftd-management"
    }
  )
}

# Diagnostic interface
resource "aws_network_interface" "ftd_diagnostic" {
  description     = "ftd-diagnostic"
  subnet_id       = aws_subnet.management.id
  security_groups = [aws_security_group.management_access.id]

  tags = merge(
    local.tags,
    {
      Name = "ftd-diagnostic"
    }
  )
}

# Outside outside
resource "aws_network_interface" "ftd_outside" {
  description     = "ftd-outside"
  subnet_id       = aws_subnet.outside.id
  security_groups = [aws_security_group.outside_access.id]

  tags = merge(
    local.tags,
    {
      Name = "ftd-outside"
    }
  )
}

resource "aws_eip" "outside" {
  vpc = true
  network_interface = aws_network_interface.ftd_outside.id
}

# Outside outside
resource "aws_network_interface" "ftd_inside" {
  description     = "ftd-inside"
  subnet_id       = aws_subnet.inside.id
  security_groups = [aws_security_group.inside_access.id]

  tags = merge(
    local.tags,
    {
      Name = "ftd-inside"
    }
  )
}

# FTD Firewall
resource "aws_instance" "ftd" {
  ami                         = data.aws_ami.ftdv_7_3.id
  instance_type               = "c5.xlarge"
  key_name                    = var.ssh_key
  user_data_replace_on_change = true
  user_data                   = jsonencode(
    {
      "AdminPassword": var.admin_password!=""?var.admin_password:random_password.password.result
      "Hostname": "ftd",
      "FirewallMode": "Routed",
      "ManageLocally": "No",
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.ftd_management.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.ftd_diagnostic.id
    device_index         = 1
  }
  network_interface {
    network_interface_id = aws_network_interface.ftd_outside.id
    device_index         = 2
  }
  network_interface {
    network_interface_id = aws_network_interface.ftd_inside.id
    device_index         = 3
  }

  tags = merge(
    local.tags,
    {
      Name = "ftd"
    }
  )
}