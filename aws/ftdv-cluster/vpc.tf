# App1 VPC
resource "aws_vpc" "app1" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "app_vpc1"
    Project = "gwlb"
  }
}

# App2 VPC
resource "aws_vpc" "app2" {
  cidr_block           = "10.2.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "app_vpc2"
    Project = "gwlb"
  }
}

# Firewall VPC
resource "aws_vpc" "fw" {
  cidr_block           = "10.100.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "fw_vpc"
    Project = "gwlb"
  }
}

# Internet VPC
resource "aws_vpc" "inet" {
  cidr_block           = "10.200.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "inet_vpc"
    Project = "gwlb"
  }
}

# Management subnet
resource "aws_subnet" "mgm" {
  vpc_id            = aws_vpc.mgm.id
  cidr_block        = cidrsubnet(aws_vpc.mgm.cidr_block, 8, 1)
  availability_zone = var.app_azs[0]
  tags = {
    Name    = "mgm_vpc_subnet"
    Project = "gwlb"
  }
}

# One App subnet in each AZ for App1 VPC
resource "aws_subnet" "app1_srv" {
  count             = 2
  vpc_id            = aws_vpc.app1.id
  cidr_block        = cidrsubnet(aws_vpc.app1.cidr_block, 8, 1 + count.index)
  availability_zone = var.app_azs[count.index]
  tags = {
    Name    = "app_vpc1_subnet_${count.index + 1}"
    Project = "gwlb"
  }
}

# One TGW subnet in each AZ for App1 VPC
resource "aws_subnet" "app1_tgw" {
  count             = 2
  vpc_id            = aws_vpc.app1.id
  cidr_block        = cidrsubnet(aws_vpc.app1.cidr_block, 8, 11 + count.index)
  availability_zone = var.app_azs[count.index]
  tags = {
    Name    = "app_vpc1_tgw_subnet_${count.index + 1}"
    Project = "gwlb"
  }
}

# One App subnet in each AZ for App2 VPC
resource "aws_subnet" "app2_srv" {
  count             = 2
  vpc_id            = aws_vpc.app2.id
  cidr_block        = cidrsubnet(aws_vpc.app2.cidr_block, 8, 1 + count.index)
  availability_zone = var.app_azs[count.index]
  tags = {
    Name    = "app_vpc2_subnet_${count.index + 1}"
    Project = "gwlb"
  }
}

# One TGW subnet in each AZ for App2 VPC
resource "aws_subnet" "app2_tgw" {
  count             = 2
  vpc_id            = aws_vpc.app2.id
  cidr_block        = cidrsubnet(aws_vpc.app2.cidr_block, 8, 11 + count.index)
  availability_zone = var.app_azs[count.index]
  tags = {
    Name    = "app_vpc2_tgw_subnet_${count.index + 1}"
    Project = "gwlb"
  }
}

# Subnets for Firewall management Interfaces
resource "aws_subnet" "fw_management" {
  count             = local.fw_az_count
  vpc_id            = aws_vpc.fw.id
  cidr_block        = cidrsubnet(aws_vpc.fw.cidr_block, 8, 1 + count.index)
  availability_zone = var.fw_azs[count.index]
  tags = {
    Name    = "fw_vpc_management_subnet_${count.index + 1}"
    Project = "gwlb"
  }
}

# Subnets for Firewall data Interfaces
resource "aws_subnet" "fw_data" {
  count             = local.fw_az_count
  vpc_id            = aws_vpc.fw.id
  cidr_block        = cidrsubnet(aws_vpc.fw.cidr_block, 8, 5 + count.index)
  availability_zone = var.fw_azs[count.index]
  tags = {
    Name    = "fw_vpc_data_subnet_${count.index + 1}"
    Project = "gwlb"
  }
}

# Subnets for Firewall CCL Interfaces.
# Since we have to specify the range of IP addresses for CCL link, keeping this subnet small: /28
# The caculation below will generate 10.x.16.0/28,10.x.16.16/28, 10.x.16.32/28, etc.
resource "aws_subnet" "fw_ccl" {
  count             = local.fw_az_count
  vpc_id            = aws_vpc.fw.id
  cidr_block        = cidrsubnet(aws_vpc.fw.cidr_block, 12, 256 + count.index)
  availability_zone = var.fw_azs[count.index]
  tags = {
    Name    = "fw_vpc_ccl_subnet_${count.index + 1}"
    Project = "gwlb"
  }
}

# One TGW subnet in each AZ for Firewall VPC
resource "aws_subnet" "fw_tgw" {
  count             = local.fw_az_count
  vpc_id            = aws_vpc.fw.id
  cidr_block        = cidrsubnet(aws_vpc.fw.cidr_block, 8, 11 + count.index)
  availability_zone = var.fw_azs[count.index]
  tags = {
    Name    = "fw_vpc_tgw_subnet_${count.index + 1}"
    Project = "gwlb"
  }
}

# Subnets for NAT Gateways in Internet VPC
resource "aws_subnet" "inet_natgw" {
  count             = 2
  vpc_id            = aws_vpc.inet.id
  cidr_block        = cidrsubnet(aws_vpc.inet.cidr_block, 8, 11 + count.index)
  availability_zone = var.inet_azs[count.index]
  tags = {
    Name    = "inet_vpc_natgw_subnet_${count.index + 1}"
    Project = "gwlb"
  }
}

# One TGW subnet in each AZ for Internet VPC
resource "aws_subnet" "inet_tgw" {
  count             = 2
  vpc_id            = aws_vpc.inet.id
  cidr_block        = cidrsubnet(aws_vpc.inet.cidr_block, 8, 1 + count.index)
  availability_zone = var.inet_azs[count.index]
  tags = {
    Name    = "inet_vpc_tgw_subnet_${count.index + 1}"
    Project = "gwlb"
  }
}

# Generic Security Group for all access for Firewall VPC
resource "aws_security_group" "all_access" {
  vpc_id = aws_vpc.fw.id
  name   = "all-access-sg"
  tags = {
    Name    = "all-access-sg"
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
      description      = "Allow all inbound"
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
}

# Generic Security Group for all access for App1 VPC
resource "aws_security_group" "all_access_app1" {
  vpc_id = aws_vpc.app1.id
  name   = "all-access-app1-sg"
  tags = {
    Name    = "all-access-app1-sg"
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
      description      = "Allow all inbound"
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
}

# Generic Security Group for all access for App2 VPC
resource "aws_security_group" "all_access_app2" {
  vpc_id = aws_vpc.app2.id
  name   = "all-access-app2-sg"
  tags = {
    Name    = "all-access-app2-sg"
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
      description      = "Allow all inbound"
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
}