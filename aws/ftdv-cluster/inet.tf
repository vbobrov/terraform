# Route tables for inbound traffic into Internet VPC
resource "aws_route_table" "inet" {
  count  = 2
  vpc_id = aws_vpc.inet.id
  tags = {
    Name    = "inet_rt_${count.index + 1}"
    Project = "gwlb"
  }
}

# Route tables attached on TGW subnets
resource "aws_route_table_association" "inet_tgw" {
  count          = 2
  subnet_id      = aws_subnet.inet_tgw[count.index].id
  route_table_id = aws_route_table.inet[count.index].id
}

# Default routes on the TGW route tables in Internet VPC point to NAT Gateway
resource "aws_route" "inet_dfgw" {
  count                  = 2
  route_table_id         = aws_route_table.inet[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw[count.index].id
}

# --------------------------------------------------
# Route tables for traffic from NAT Gateways
resource "aws_route_table" "natgw" {
  count  = 2
  vpc_id = aws_vpc.inet.id
  tags = {
    Name    = "inet_natgw_rt_${count.index + 1}"
    Project = "gwlb"
  }
}

resource "aws_route_table_association" "inet_natgw" {
  count          = 2
  subnet_id      = aws_subnet.inet_natgw[count.index].id
  route_table_id = aws_route_table.natgw[count.index].id
}

# Default routes on NAT GW route tables in Internet VPC point to Internet Gateway
resource "aws_route" "inet_natgw_dfgw" {
  count                  = 2
  route_table_id         = aws_route_table.natgw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inet_gw.id
}

# Routes in NAT GW route table for App1 CiDR block point to Transit Gateway
resource "aws_route" "inet_app1" {
  count                  = 2
  route_table_id         = aws_route_table.natgw[count.index].id
  destination_cidr_block = aws_vpc.app1.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Routes in NAT GW route table for App2 CiDR block point to Transit Gateway
resource "aws_route" "inet_app2" {
  count                  = 2
  route_table_id         = aws_route_table.natgw[count.index].id
  destination_cidr_block = aws_vpc.app2.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# Routes in NAT GW route table for FW CiDR block point to Transit Gateway
# This is needed for FTDs to be able to reach the Internet for Smart Licensing
resource "aws_route" "inet_fw" {
  count                  = 2
  route_table_id         = aws_route_table.natgw[count.index].id
  destination_cidr_block = aws_vpc.fw.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
}

# ---------------------------------------------
# One NAT GW is provisioned per AZ
resource "aws_nat_gateway" "nat_gw" {
  count         = 2
  allocation_id = aws_eip.nat_gw[count.index].id
  subnet_id     = aws_subnet.inet_natgw[count.index].id
  depends_on    = [aws_internet_gateway.inet_gw]
  tags = {
    Name    = "nat_gw_${count.index + 1}"
    Project = "gwlb"
  }
}

# Public IP of the NAT Gateway
resource "aws_eip" "nat_gw" {
  count = 2
}

# Internet Gateway is required for NAT Gateway to be able to reach the Internet
resource "aws_internet_gateway" "inet_gw" {
  vpc_id = aws_vpc.inet.id
}