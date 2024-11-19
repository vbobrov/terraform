data "aws_ami" "ubuntu_24_pro" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["ubuntu-pro-server/images/hvm-ssd-gp3/ubuntu-noble-24*"]
  }
}

data "aws_ami" "ubuntu_24" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["dv93d44qq5nae4el2oecv6xwa"]
  }
}

resource "aws_network_interface" "radius" {
  count           = var.radius_count
  description     = "radius-${count.index + 1}"
  subnet_id       = aws_subnet.adc_internal.id
  security_groups = [aws_security_group.full_access.id]
  tags = {
    Name = "adc-radius-${count.index + 1}"
  }
}

resource "aws_instance" "radius" {
  count                       = var.radius_count
  ami                         = data.aws_ami.ubuntu_24.id
  instance_type               = "t1.micro"
  key_name                    = var.ssh_key_name
  user_data_replace_on_change = true

  network_interface {
    network_interface_id = aws_network_interface.radius[count.index].id
    device_index         = 0
  }

  user_data = <<-EOT
    #!/bin/bash
    apt -y update
    apt -y install freeradius freeradius-utils
    cat >>/etc/freeradius/3.0/clients.conf <<EOF
    client aws {
        ipaddr = 10.1.0.0/16
        secret = cisco
        require_message_authenticator = no
    }
    EOF
    cat >>/etc/freeradius/3.0/users <<EOF
    cisco Cleartext-Password := "cisco"
          Reply-Message := "RADIUS-${count.index + 1}"
    EOF
    sed -i 's/auth = no/auth = yes/' /etc/freeradius/3.0/radiusd.conf
    sed -i 's/#.*msg_goodpass = ""/        msg_goodpass = "%%{Client-IP-Address}"/' /etc/freeradius/3.0/radiusd.conf
    systemctl restart freeradius
  EOT

  depends_on = [time_sleep.adc]
  tags = {
    Name = "adc-radius-${count.index + 1}"
  }
}

