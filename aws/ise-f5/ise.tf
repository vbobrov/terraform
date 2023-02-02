data "aws_ami" "ise_32" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name   = "name"
    values = ["Cisco Identity Services Engine (ISE) v3.2*"]
  }
}

resource "aws_instance" "ise" {
  count                       = var.ise_count
  ami                         = data.aws_ami.ise_32.id
  instance_type               = "t3.xlarge"
  key_name                    = "aws-ssh-1"
  subnet_id                   = aws_subnet.f5_internal.id
  associate_public_ip_address = false
  user_data_replace_on_change = true
  vpc_security_group_ids      = [aws_security_group.full_access.id]
  ebs_block_device {
    device_name = "/dev/sda1"
    delete_on_termination = true
  }
  user_data                   = <<-EOT
    hostname=ise-${count.index+1}
    dnsdomain=aws.ciscodemo.net
    primarynameserver=169.254.169.253
    ntpserver=169.254.169.123
    username=iseadmin
    password=${random_password.password.result}
    timezone=Etc/UTC
    ersapi=yes
    openapi=yes
    pxGrid=no
    pxgrid_cloud=no
  EOT
  tags = merge(
    local.tags,
    {
      Name = "ise-${count.index + 1}"
    }
  )
}
