# Management VPC
resource "aws_vpc" "mgm" {
  cidr_block           = "10.255.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "mgm_vpc1"
    Project = "gwlb"
  }
}

# TGW subnet for Management VPC
resource "aws_subnet" "mgm_tgw" {
  vpc_id            = aws_vpc.mgm.id
  cidr_block        = cidrsubnet(aws_vpc.mgm.cidr_block, 8, 11)
  availability_zone = var.fw_azs[0]
  tags = {
    Name    = "mgm_vpc_tgw_subnet"
    Project = "gwlb"
  }
}

# Route tables for Management VPC
resource "aws_route_table" "mgm" {
  vpc_id = aws_vpc.mgm.id
  tags = {
    Name    = "mgm_rt"
    Project = "gwlb"
  }
}

# Route tables attached on Management Subnet
resource "aws_route_table_association" "mgm" {
  subnet_id      = aws_subnet.mgm.id
  route_table_id = aws_route_table.mgm.id
}

# Route to Firewall VPC CIDR on Management VPC via Transit Gateway
resource "aws_route" "mgm_fw" {
  route_table_id         = aws_route_table.mgm.id
  destination_cidr_block = aws_vpc.fw.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Route to App1 VPC CIDR on Management VPC via Transit Gateway
resource "aws_route" "mgm_app1" {
  route_table_id         = aws_route_table.mgm.id
  destination_cidr_block = aws_vpc.app1.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Route to App2 VPC CIDR on Management VPC via Transit Gateway
resource "aws_route" "mgm_app2" {
  route_table_id         = aws_route_table.mgm.id
  destination_cidr_block = aws_vpc.app2.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}


# Internet Gateway for Management VPC
resource "aws_internet_gateway" "mgm_inet_gw" {
  vpc_id = aws_vpc.mgm.id
}

# Default routes on Management route table points to Internet Gateway
resource "aws_route" "mgm_dfgw" {
  route_table_id         = aws_route_table.mgm.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mgm_inet_gw.id
}

resource "aws_instance" "jumphost" {
  ami                         = data.aws_ami.ami_linux.id
  instance_type               = "t2.micro"
  key_name                    = "aws-ssh-1"
  subnet_id                   = aws_subnet.mgm.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.management_access.id]
  tags = {
    Name    = "mgm_jumphost"
    Project = "gwlb"
  }
}

resource "aws_security_group" "management_access" {
  vpc_id = aws_vpc.mgm.id
  name   = "management-access-sg"
  tags = {
    Name    = "management-access-sg"
    Project = "gwlb"
  }
  egress = [
    {
      description      = "Allow all outbound"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  ingress = [
    {
      description      = "Allow SSH for Management"
      from_port        = 22
      to_port          = 22
      protocol         = "TCP"
      cidr_blocks      = var.ssh_sources
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

# Route to Management CIDR on Firewall VPC Route Table
resource "aws_ec2_transit_gateway_route" "fw_mgm_cidr" {
  destination_cidr_block         = aws_vpc.mgm.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgm.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.fw.id
}

# Route to Management CIDR on App Route Table
resource "aws_ec2_transit_gateway_route" "app_mgm_cidr" {
  destination_cidr_block         = aws_vpc.mgm.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgm.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app.id
}

# TGW Attachment to Management VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "mgm" {
  subnet_ids                                      = [aws_subnet.mgm_tgw.id]
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.mgm.id
  transit_gateway_default_route_table_association = false
  tags = {
    Name    = "mgm_attachment"
    Project = "gwlb"
  }
}

#--------------------------------------
# TGW Route Table for Management VPCs.
resource "aws_ec2_transit_gateway_route_table" "mgm" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name    = "mgm_tgw_rt"
    Project = "gwlb"
  }
}

# TGW Route Table Management VPC Association
resource "aws_ec2_transit_gateway_route_table_association" "mgm_tgw_rt_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.mgm.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.mgm.id
}

# Route to App1 CIDR on Management TGW Route Table
resource "aws_ec2_transit_gateway_route" "mgm_app1" {
  destination_cidr_block         = aws_vpc.app1.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.mgm.id
}

# Route to App2 CIDR on Management TGW Route Table
resource "aws_ec2_transit_gateway_route" "mgm_app2" {
  destination_cidr_block         = aws_vpc.app2.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.mgm.id
}

# Route to Firewall CIDR on Management TGW Route Table
resource "aws_ec2_transit_gateway_route" "mgm_fw" {
  destination_cidr_block         = aws_vpc.fw.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.fw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.mgm.id
}