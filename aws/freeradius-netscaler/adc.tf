resource "aws_network_interface" "adc_management" {
  description     = "adc-management"
  subnet_id       = aws_subnet.adc_management.id
  security_groups = [aws_security_group.full_access.id]
  tags = {
    Name = "adc-management"
  }
}

resource "aws_network_interface" "adc_internal" {
  description       = "adc-internal"
  subnet_id         = aws_subnet.adc_internal.id
  security_groups   = [aws_security_group.full_access.id]
  source_dest_check = false
  tags = {
    Name = "adc-internal"
  }
}

resource "aws_network_interface" "adc_external" {
  description       = "adc_external"
  subnet_id         = aws_subnet.adc_external.id
  security_groups   = [aws_security_group.full_access.id]
  source_dest_check = false
  tags = {
    Name = "adc-external"
  }
}

resource "aws_eip" "adc_external" {
  domain            = "vpc"
  network_interface = aws_network_interface.adc_external.id
  tags = {
    Name = "adc-external"
  }
}

data "aws_ami" "adc_14" {
  most_recent        = true
  owners             = ["679593333241"]
  include_deprecated = true
  filter {
    name   = "name"
    values = ["Citrix ADC 14*"]
  }
  filter {
    name   = "product-code"
    values = ["cymftlvlisozf6bcoobcdj7e8"]
  }
}

resource "aws_instance" "adc" {
  ami                         = data.aws_ami.adc_14.id
  instance_type               = "t2.medium"
  key_name                    = var.ssh_key_name
  user_data_replace_on_change = true
  user_data = templatefile("adc-config.tftpl",
    {
      management_gw   = cidrhost(aws_subnet.adc_management.cidr_block, 1)
      external_ip     = aws_network_interface.adc_external.private_ip
      external_mask   = cidrnetmask(aws_subnet.adc_external.cidr_block)
      external_gw     = cidrhost(aws_subnet.adc_external.cidr_block, 1)
      internal_ip     = aws_network_interface.adc_internal.private_ip
      internal_net    = cidrhost(aws_subnet.adc_internal.cidr_block, 0)
      internal_mask   = cidrnetmask(aws_subnet.adc_internal.cidr_block)
      servers         = aws_network_interface.radius.*.private_ip
      vip             = cidrhost(var.adc_vip_cidr, 1)
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.adc_management.id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.adc_external.id
    device_index         = 1
  }
  network_interface {
    network_interface_id = aws_network_interface.adc_internal.id
    device_index         = 2
  }
  tags = {
    Name = "adc"
  }
}

resource "time_sleep" "adc" {
  depends_on      = [aws_instance.adc]
  create_duration = "5m"

  triggers = {
    instance_id = aws_instance.adc.id
  }
}