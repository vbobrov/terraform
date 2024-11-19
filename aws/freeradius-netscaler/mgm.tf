data "aws_ami" "ami_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "mgm" {
  ami                         = data.aws_ami.ubuntu_24.id
  instance_type               = "t1.micro"
  key_name                    = var.ssh_key_name
  subnet_id                   = aws_subnet.adc_external.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.management_access.id]

  tags = {
    Name = "adc-mgm"
  }
}
