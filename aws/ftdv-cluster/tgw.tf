# Provisions resources related to Transit Gateway
# All attachments for TGW utilize two subnets provisioned specifically for TGW in each VPC


# Transit Gateway
resource "aws_ec2_transit_gateway" "tgw" {
  description = "gwlb_tgw"

  tags = {
    Name    = "gwlb_tgw"
    Project = "gwlb"
  }
}

# TGW Attachment to firewall VPC
# Only used to get to management interface
resource "aws_ec2_transit_gateway_vpc_attachment" "fw" {
  subnet_ids                                      = aws_subnet.fw_tgw.*.id
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.fw.id
  transit_gateway_default_route_table_association = false
  appliance_mode_support = "enable"
  tags = {
    Name    = "fw_attachment"
    Project = "gwlb"
  }
}

#TGW Attachment to App1 VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "app1" {
  subnet_ids                                      = aws_subnet.app1_tgw.*.id
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.app1.id
  transit_gateway_default_route_table_association = false
  tags = {
    Name    = "app1_attachment"
    Project = "gwlb"
  }
}

# TGW Attachment to App2 VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "app2" {
  subnet_ids                                      = aws_subnet.app2_tgw.*.id
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.app2.id
  transit_gateway_default_route_table_association = false
  tags = {
    Name    = "app2_attachment"
    Project = "gwlb"
  }
}

# TGW Attachment to Internet VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "inet" {
  subnet_ids                                      = aws_subnet.inet_tgw.*.id
  transit_gateway_id                              = aws_ec2_transit_gateway.tgw.id
  vpc_id                                          = aws_vpc.inet.id
  transit_gateway_default_route_table_association = false
  tags = {
    Name    = "inet_attachment"
    Project = "gwlb"
  }
}

#---------------------------------------------
# TGW Route Table for Firewall VPC
resource "aws_ec2_transit_gateway_route_table" "fw" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name    = "fw_rt"
    Project = "gwlb"
  }
}

# TGW Route Table Firewall VPC Attachment
resource "aws_ec2_transit_gateway_route_table_association" "fw" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.fw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.fw.id
}

# Route to App1 CIDR on Firewall VPC Route Table
resource "aws_ec2_transit_gateway_route" "app1" {
  destination_cidr_block         = aws_vpc.app1.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.fw.id
}

# Route to App2 CIDR on Firewall VPC Route Table
resource "aws_ec2_transit_gateway_route" "app2" {
  destination_cidr_block         = aws_vpc.app2.cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.fw.id
}

# Default gateway on Firewall Route Table points to Internet VPC Attachment
resource "aws_ec2_transit_gateway_route" "fw_dfg" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inet.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.fw.id
}

#-------------------------------------------------
# TGW Route Table for App VPCs. Same RT is applied to both App VPCs
resource "aws_ec2_transit_gateway_route_table" "app" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name    = "app_tgw_rt"
    Project = "gwlb"
  }
}

# TGW Route Table App1 VPC Association
resource "aws_ec2_transit_gateway_route_table_association" "app1" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app1.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app.id
}

# TGW Route Table App2 VPC Association
resource "aws_ec2_transit_gateway_route_table_association" "app2_tgw_rt_assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.app2.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app.id
}

# Default gateway on App Route Table points to Internet VPC Attachment
resource "aws_ec2_transit_gateway_route" "app_dfg" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.fw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.app.id
}

#--------------------------------------
# TGW Route Table for Internet VPCs.
resource "aws_ec2_transit_gateway_route_table" "inet" {
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  tags = {
    Name    = "inet_tgw_rt"
    Project = "gwlb"
  }
}

# TGW Route Table Internet VPC Association
resource "aws_ec2_transit_gateway_route_table_association" "inet" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inet.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inet.id
}

# Route to FW Management Subnets on Internet Route Table points to FW VPC Attachment
resource "aws_ec2_transit_gateway_route" "inet_fw_management" {
  count                          = local.fw_az_count
  destination_cidr_block         = aws_subnet.fw_management[count.index].cidr_block
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.fw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inet.id
}

# Default gateway on Internet Route Table points to FW VPC Attachment
resource "aws_ec2_transit_gateway_route" "inet_dfg" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.fw.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inet.id
}