# Firewall VPC
resource "aws_vpc" "fw" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    local.tags,
    {
      Name = "ftd"
    }
  )
}

# Subnets for Firewall management Interfaces and FMC
resource "aws_subnet" "management" {
  vpc_id            = aws_vpc.fw.id
  cidr_block        = cidrsubnet(aws_vpc.fw.cidr_block, 8, 1)
  availability_zone = var.az


  tags = merge(
    local.tags,
    {
      Name = "management"
    }
  )
}

# Subnets for Firewall outside Interfaces
resource "aws_subnet" "outside" {
  vpc_id            = aws_vpc.fw.id
  cidr_block        = cidrsubnet(aws_vpc.fw.cidr_block, 8, 2)
  availability_zone = var.az

  tags = merge(
    local.tags,
    {
      Name = "outside"
    }
  )
}

# Subnets for Firewall inside Interfaces
resource "aws_subnet" "inside" {
  vpc_id            = aws_vpc.fw.id
  cidr_block        = cidrsubnet(aws_vpc.fw.cidr_block, 8, 3)
  availability_zone = var.az

  tags = merge(
    local.tags,
    {
      Name = "inside"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "fw" {
  vpc_id = aws_vpc.fw.id
  tags = merge(
    local.tags,
    {
      Name = "inside"
    }
  )
}

# Default route pointing to Internet Gateway
resource "aws_route" "main_default_gw" {
  route_table_id         = aws_vpc.fw.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.fw.id
}

# Route Table for FTD Inside Subnet
resource "aws_route_table" "inside" {
  vpc_id = aws_vpc.fw.id
  tags = merge(
    local.tags,
    {
      Name = "inside"
    }
  )
}

# Association to inside subnet
resource "aws_route_table_association" "inside" {
  subnet_id      = aws_subnet.inside.id
  route_table_id = aws_route_table.inside.id
}

# Routes to SSH Sources to bypass the firewall
resource "aws_route" "ssh_sources" {
  count = length(var.ssh_sources)
  route_table_id         = aws_route_table.inside.id
  destination_cidr_block = var.ssh_sources[count.index]
  gateway_id             = aws_internet_gateway.fw.id
}

# Default GW pointing to inside interface of the router
resource "aws_route" "inside_default" {
  route_table_id         = aws_route_table.inside.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.ftd_inside.id
}

resource "aws_security_group" "management_access" {
  vpc_id = aws_vpc.fw.id
  name   = "management-access"

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
    },
    {
      description      = "Allow HTTPS for Management"
      from_port        = 443
      to_port          = 443
      protocol         = "TCP"
      cidr_blocks      = var.ssh_sources
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Allow Full Access from inside SG"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = [aws_security_group.inside_access.id]
      self             = false
    },
    {
      description      = "Allow Full Access from the same SG"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = true
    }
  ]
  tags = merge(
    local.tags,
    {
      Name = "management-access"
    }
  )
}


# Security Group for inside access
resource "aws_security_group" "inside_access" {
  vpc_id = aws_vpc.fw.id
  name   = "inside-access"

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

  tags = merge(
    local.tags,
    {
      Name = "inside-access"
    }
  )
}

# Security Group for inside access
resource "aws_security_group" "outside_access" {
  vpc_id = aws_vpc.fw.id
  name   = "outside-access"

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
      description      = "Allow TLS inbound"
      from_port        = 443
      to_port          = 443
      protocol         = "TCP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "Allow DTLS inbound"
      from_port        = 443
      to_port          = 443
      protocol         = "UDP"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  tags = merge(
    local.tags,
    {
      Name = "outside-access"
    }
  )
}