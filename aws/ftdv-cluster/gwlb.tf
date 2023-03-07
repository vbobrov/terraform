# Gateway Load Balancing related resources 
resource "aws_lb" "gwlb" {
  name                             = "gwlb"
  load_balancer_type               = "gateway"
  subnets                          = aws_subnet.fw_data.*.id
  enable_cross_zone_load_balancing = true

  tags = {
    Name    = "gwlb"
    Project = "gwlb"
  }
}

# Target group is IP based since FTD's are provisioned with multiple interfaces
resource "aws_lb_target_group" "ftd" {
  name        = "ftdtg"
  protocol    = "GENEVE"
  vpc_id      = aws_vpc.fw.id
  target_type = "ip"
  port        = 6081
  stickiness {
    type = "source_ip_dest_ip"
  }
  health_check {
    port     = 12345
    protocol = "TCP"
  }
}

# Target group is attached to IP addresss of data interfaces
resource "aws_lb_target_group_attachment" "ftd" {
  count            = local.fw_az_count * var.fw_per_az
  target_group_arn = aws_lb_target_group.ftd.arn
  target_id        = aws_network_interface.ftd_data[count.index].private_ip
}

# GWLB Listener
resource "aws_lb_listener" "cluster" {
  load_balancer_arn = aws_lb.gwlb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ftd.arn
  }
}

# Endpoint Service
resource "aws_vpc_endpoint_service" "gwlb" {
  acceptance_required        = false
  gateway_load_balancer_arns = [aws_lb.gwlb.arn]
  tags = {
    Name    = "gwlb_endpoint_service"
    Project = "gwlb"
  }
}

# GWLB Endpoints. One is required for each AZ in App1 VPC
resource "aws_vpc_endpoint" "fw" {
  count             = local.fw_az_count
  service_name      = aws_vpc_endpoint_service.gwlb.service_name
  vpc_endpoint_type = aws_vpc_endpoint_service.gwlb.service_type
  vpc_id            = aws_vpc.fw.id
  tags = {
    Name    = "fw_gwlb_endpoint_${count.index + 1}"
    Project = "gwlb"
  }
}

# Delay after GWLB Endpoint creation
resource "time_sleep" "fw" {
  create_duration = "120s"
  depends_on = [
    aws_vpc_endpoint.fw
  ]
}

# GWLB Endpoints are placed in FW Data subnets in Firewall VPC
resource "aws_vpc_endpoint_subnet_association" "fw" {
  count           = local.fw_az_count
  vpc_endpoint_id = aws_vpc_endpoint.fw[count.index].id
  subnet_id       = aws_subnet.fw_data[count.index].id
}
