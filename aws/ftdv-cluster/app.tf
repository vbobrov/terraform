# Provisions test Amazon Linux Instances

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

# Instances in App1 VPC
resource "aws_instance" "app1_linux" {
  count         = 2
  ami           = data.aws_ami.ami_linux.id
  instance_type = "t2.micro"
  key_name      = var.ssh_key
  subnet_id     = aws_subnet.app1_srv[count.index].id
  vpc_security_group_ids = [
    aws_security_group.all_access_app1.id,
  ]
  tags = {
    Name    = "app_vpc1_linux_${count.index + 1}"
    Project = "gwlb"
  }
}

# Instances in App2 VPC
resource "aws_instance" "app2_linux" {
  count         = 2
  ami           = data.aws_ami.ami_linux.id
  instance_type = "t2.micro"
  key_name      = var.ssh_key
  subnet_id     = aws_subnet.app2_srv[count.index].id
  vpc_security_group_ids = [
    aws_security_group.all_access_app2.id
  ]
  tags = {
    Name    = "app_vpc2_linux_${count.index + 1}"
    Project = "gwlb"
  }
}