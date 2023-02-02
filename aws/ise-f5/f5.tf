resource "aws_network_interface" "f5_management" {
  description       = "f5-management"
  subnet_id         = aws_subnet.f5_external.id
  security_groups   = [aws_security_group.full_access.id]
  tags = merge(
    local.tags,
    {
      Name = "f5-management"
    }
  )
}

resource "aws_network_interface" "f5_internal" {
  description       = "f5-internal"
  subnet_id         = aws_subnet.f5_internal.id
  security_groups   = [aws_security_group.full_access.id]
  source_dest_check = false
  tags = merge(
    local.tags,
    {
      Name = "f5-internal"
    }
  )
}

resource "aws_network_interface" "f5_external" {
  description       = "f5_external"
  subnet_id         = aws_subnet.f5_external.id
  security_groups   = [aws_security_group.full_access.id]
  source_dest_check = false
  tags = merge(
    local.tags,
    {
      Name = "f5-external"
    }
  )
}

data "aws_ami" "f5_16" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name   = "name"
    values = ["F5 BIGIP-16*"]
  }
  filter {
    name   = "product-code"
    values = ["8esk90vx7v713sa0muq2skw3j"]
  }
}

resource "aws_instance" "f5" {
  ami                         = data.aws_ami.f5_16.id
  instance_type               = "c5.xlarge"
  key_name                    = "aws-ssh-1"
  user_data_replace_on_change = true
  user_data = templatefile("f5-cloud-init.tftpl",
    {
      admin_password = random_password.password.result
      internal_ip    = aws_network_interface.f5_internal.private_ip
      external_ip    = aws_network_interface.f5_external.private_ip
      external_gw    = cidrhost(aws_subnet.f5_external.cidr_block, 1)
      ise_nodes       = [ for i in range(length(aws_instance.ise)): {"name":"ise-${i+1}","ip":aws_instance.ise[i].private_ip}]
      ise_vip        = cidrhost(var.f5_vip_cidr,1)
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.f5_management.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.f5_external.id
    device_index         = 1
  }
  network_interface {
    network_interface_id = aws_network_interface.f5_internal.id
    device_index         = 2
  }
  tags = merge(
    local.tags,
    {
      Name = "f5-ise"
    }
  )
}
