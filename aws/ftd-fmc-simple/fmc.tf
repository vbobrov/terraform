# Provisions FTD firewall
data "aws_ami" "fmc_7_3" {
  most_recent = true
  owners      = ["679593333241"]
  filter {
    name   = "name"
    values = ["fmcv-7.3*"]
  }
  filter {
    name   = "product-code"
    values = ["bhx85r4r91ls2uwl69ajm9v1b"]
  }
}

resource "aws_instance" "fmc" {
  ami                         = data.aws_ami.fmc_7_3.id
  instance_type               = "c5.4xlarge"
  key_name                    = var.ssh_key
  subnet_id                   = aws_subnet.management.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.management_access.id]
  user_data_replace_on_change = true
  user_data                   = jsonencode(
    {
      "AdminPassword": var.admin_password!=""?var.admin_password:random_password.password.result,
      "Hostname": "fmc",
    }
  )
  tags = merge(
    local.tags,
    {
      Name = "fmc"
    }
  )
}