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

resource "aws_instance" "mgm" {
  ami                         = data.aws_ami.ami_linux.id
  instance_type               = "t2.micro"
  key_name                    = "aws-ssh-1"
  subnet_id                   = aws_subnet.f5_external.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.management_access.id]
  user_data                   = <<-EOT
    #!/bin/bash
    amazon-linux-extras install epel -y
    yum-config-manager --enable epel
    yum update -y
    pip3 install ansible
    pip3 install urllib3
    pip3 install ciscoisesdk
    /usr/local/bin/ansible-galaxy collection install cisco.ise -p /usr/local/lib/python3.7/site-packages/
  EOT

  connection {
    type = "ssh"
    user = "ec2-user"
    host = self.public_ip
    private_key = file("~/.ssh/aws-ssh-1.pem")
    agent = false
  }

  provisioner "remote-exec" {
    inline = ["sudo cloud-init status --wait"]
  }

  tags = merge(
    local.tags,
    {
      Name = "ise-mgm"
    }
  )
}
