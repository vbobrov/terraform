resource "aws_vpc" "ise" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    local.tags,
    {
      Name = "ise-vpc"
    }
  )
}

resource "aws_internet_gateway" "inet" {
  vpc_id = aws_vpc.ise.id
  tags = merge(
    local.tags,
    {
      Name = "ise-internet-gateway"
    }
  )
}

resource "aws_subnet" "f5_internal" {
  vpc_id            = aws_vpc.ise.id
  cidr_block        = cidrsubnet(aws_vpc.ise.cidr_block, 8, 1)
  availability_zone = "us-east-1a"
  tags = merge(
    local.tags,
    {
      Name = "f5-internal"
    }
  )
}

resource "aws_subnet" "f5_external" {
  vpc_id            = aws_vpc.ise.id
  cidr_block        = cidrsubnet(aws_vpc.ise.cidr_block, 8, 2)
  availability_zone = "us-east-1a"
  tags = merge(
    local.tags,
    {
      Name = "f5-external"
    }
  )
}

resource "aws_route_table" "f5_internal" {
  vpc_id = aws_vpc.ise.id
  tags = merge(
    local.tags,
    {
      Name = "f5-internal"
    }
  )
}

resource "aws_route" "f5_internal2external" {
  route_table_id         = aws_route_table.f5_internal.id
  destination_cidr_block = aws_subnet.f5_external.cidr_block
  network_interface_id   = aws_network_interface.f5_internal.id
}

resource "aws_route" "f5_internal_default" {
  route_table_id         = aws_route_table.f5_internal.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.f5_internal.id
}

resource "aws_route_table_association" "f5_internal" {
  subnet_id      = aws_subnet.f5_internal.id
  route_table_id = aws_route_table.f5_internal.id
}

resource "aws_route_table" "f5_external" {
  vpc_id = aws_vpc.ise.id
  tags = merge(
    local.tags,
    {
      Name = "f5-external"
    }
  )
}

resource "aws_route" "f5_external_default" {
  route_table_id         = aws_route_table.f5_external.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inet.id
}

resource "aws_route" "f5_external2internal" {
  route_table_id         = aws_route_table.f5_external.id
  destination_cidr_block = aws_subnet.f5_internal.cidr_block
  network_interface_id   = aws_network_interface.f5_external.id
}

resource "aws_route" "f5_vip_cidr" {
  route_table_id         = aws_route_table.f5_external.id
  destination_cidr_block = var.f5_vip_cidr
  network_interface_id   = aws_network_interface.f5_external.id
}

resource "aws_route_table_association" "f5_external" {
  subnet_id      = aws_subnet.f5_external.id
  route_table_id = aws_route_table.f5_external.id
}

resource "aws_security_group" "management_access" {
  name   = "ise-managment-access"
  vpc_id = aws_vpc.ise.id
  tags = merge(
    local.tags,
    {
      Name = "ise-management-access"
    }
  )
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
      description      = "Allow SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "TCP"
      cidr_blocks      = var.ssh_sources
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
  ]
}

resource "aws_security_group" "full_access" {
  name   = "ise-full-access"
  vpc_id = aws_vpc.ise.id
  tags = merge(
    local.tags,
    {
      Name = "ise-full-access"
    }
  )
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
    },
  ]
}