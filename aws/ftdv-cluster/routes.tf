# VPC Route Tables and Routes

# Default gateway on App1 Route Table pointing to Transit Gateway
resource "aws_route" "app1_dfgw" {
  route_table_id         = aws_vpc.app1.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Default gateway on App2 Route Table pointing to Transit Gateway
resource "aws_route" "app2_dfgw" {
  route_table_id         = aws_vpc.app2.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Firewall VPC Route Table for FTD subnets
resource "aws_route_table" "fw_management" {
  vpc_id = aws_vpc.fw.id
  tags = {
    Name    = "fw_rt"
    Project = "gwlb"
  }
}

# Association to Firewall management subnets
resource "aws_route_table_association" "fw_management" {
  count          = local.fw_az_count
  subnet_id      = aws_subnet.fw_management[count.index].id
  route_table_id = aws_route_table.fw_management.id
}

# Default gateway on Firewall Route Table pointing to Transit Gateway
resource "aws_route" "fw_dfgw" {
  route_table_id         = aws_route_table.fw_management.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Firewall VPC Route Table for FTD data subnets
resource "aws_route_table" "fw_data" {
  vpc_id = aws_vpc.fw.id
  tags = {
    Name    = "fw_data"
    Project = "gwlb"
  }
}

# Association to Firewall data subnets
resource "aws_route_table_association" "fw_data" {
  count          = local.fw_az_count
  subnet_id      = aws_subnet.fw_data[count.index].id
  route_table_id = aws_route_table.fw_data.id
}

# Default gateway on Firewall Route Table pointing to Transit Gateway
resource "aws_route" "fw_data_dfgw" {
  route_table_id         = aws_route_table.fw_data.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Firewall VPC Route Table for FTD data subnets
resource "aws_route_table" "fw_tgw" {
  count  = local.fw_az_count
  vpc_id = aws_vpc.fw.id
  tags = {
    Name    = "fw_tgw"
    Project = "gwlb"
  }
}

# Association to Firewall data subnets
resource "aws_route_table_association" "fw_tgw" {
  count          = local.fw_az_count
  subnet_id      = aws_subnet.fw_tgw[count.index].id
  route_table_id = aws_route_table.fw_tgw[count.index].id
}

# Default gateway on Firewall TGW Route Table pointing to GWLB endpoint
resource "aws_route" "fw_tgw_dfgw" {
  count                  = local.fw_az_count
  route_table_id         = aws_route_table.fw_tgw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = aws_vpc_endpoint.fw[count.index].id
  depends_on = [
    time_sleep.fw
  ]
}