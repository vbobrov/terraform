data "aws_ami" "ami_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "client" {
  ami                         = data.aws_ami.ami_linux.id
  instance_type               = "t2.micro"
  key_name                    = "aws-ssh-1"
  subnet_id                   = aws_subnet.inside.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.management_access.id]

  tags = merge(
    local.tags,
    {
      Name = "client"
    }
  )
}
