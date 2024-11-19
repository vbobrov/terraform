resource "aws_vpc" "adc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "adc-vpc"
  }
}

resource "aws_internet_gateway" "adc" {
  vpc_id = aws_vpc.adc.id
  tags = {
    Name = "adc-internet-gateway"
  }
}

resource "aws_subnet" "adc_internal" {
  vpc_id            = aws_vpc.adc.id
  cidr_block        = cidrsubnet(aws_vpc.adc.cidr_block, 8, 1)
  availability_zone = "us-east-1a"
  tags = {
    Name = "adc-internal"
  }
}

resource "aws_subnet" "adc_external" {
  vpc_id            = aws_vpc.adc.id
  cidr_block        = cidrsubnet(aws_vpc.adc.cidr_block, 8, 2)
  availability_zone = "us-east-1a"
  tags = {
    Name = "adc-external"
  }
}

resource "aws_subnet" "adc_management" {
  vpc_id            = aws_vpc.adc.id
  cidr_block        = cidrsubnet(aws_vpc.adc.cidr_block, 8, 3)
  availability_zone = "us-east-1a"
  tags = {
    Name = "adc-internal"
  }
}

resource "aws_route_table" "adc_internal" {
  vpc_id = aws_vpc.adc.id
  tags = {
    Name = "adc-internal"
  }
}

resource "aws_route" "adc_internal2external" {
  route_table_id         = aws_route_table.adc_internal.id
  destination_cidr_block = aws_subnet.adc_external.cidr_block
  network_interface_id   = aws_network_interface.adc_internal.id
}

resource "aws_route" "adc_internal_default" {
  route_table_id         = aws_route_table.adc_internal.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.adc_internal.id
}

resource "aws_route_table_association" "adc_internal" {
  subnet_id      = aws_subnet.adc_internal.id
  route_table_id = aws_route_table.adc_internal.id
}

resource "aws_route_table" "adc_external" {
  vpc_id = aws_vpc.adc.id
  tags = {
    Name = "adc-external"
  }
}

resource "aws_route" "adc_external_default" {
  route_table_id         = aws_route_table.adc_external.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.adc.id
}

resource "aws_route" "adc_external2internal" {
  route_table_id         = aws_route_table.adc_external.id
  destination_cidr_block = aws_subnet.adc_internal.cidr_block
  network_interface_id   = aws_network_interface.adc_external.id
}

resource "aws_route" "adc_vip_cidr" {
  route_table_id         = aws_route_table.adc_external.id
  destination_cidr_block = var.adc_vip_cidr
  network_interface_id   = aws_network_interface.adc_external.id
}

resource "aws_route_table_association" "adc_external" {
  subnet_id      = aws_subnet.adc_external.id
  route_table_id = aws_route_table.adc_external.id
}

resource "aws_security_group" "management_access" {
  name   = "adc-managment-access"
  vpc_id = aws_vpc.adc.id
  tags = {
    Name = "adc-management-access"
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
  name   = "adc-full-access"
  vpc_id = aws_vpc.adc.id
  tags = {
    Name = "adc-full-access"
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
    },
  ]
}