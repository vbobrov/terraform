resource "aws_networkmanager_global_network" "global_network" {
  description = "Lab Network"
}

resource "aws_networkmanager_core_network" "core" {
  global_network_id = aws_networkmanager_global_network.global_network.id
}

resource "aws_networkmanager_core_network_policy_attachment" "core" {
  core_network_id = aws_networkmanager_core_network.core.id
  policy_document = data.aws_networkmanager_core_network_policy_document.cwan.json
}

data "aws_networkmanager_core_network_policy_document" "cwan" {
  core_network_configuration {
    vpn_ecmp_support = false
    asn_ranges       = ["64512-64555"]
    inside_cidr_blocks = ["10.255.0.0/16"]
  
    edge_locations {
      location = "us-east-1"
      asn      = 64512
      inside_cidr_blocks = ["10.255.0.0/24"]
    }
  }

  segments {
    name                          = "spokes"
    description                   = "All spokes"
    require_attachment_acceptance = false
  }

  segment_actions {
    action     = "share"
    mode       = "attachment-route"
    segment    = "spokes"
    share_with = ["*"]
  }

  attachment_policies {
    rule_number     = 100
    condition_logic = "or"

    conditions {
      type     = "tag-value"
      operator = "equals"
      key      = "Segment"
      value    = "spokes"
    }
    action {
      association_method = "constant"
      segment            = "spokes"
    }
  }
}
   
resource "aws_vpc" "main" {
  cidr_block           = "10.1.0.0/16"
}

resource "aws_subnet" "cwan" {
  vpc_id                   = aws_vpc.main.id
  cidr_block               = "10.1.1.0/24"
  availability_zone        = "us-east-1a"
}

resource "aws_networkmanager_vpc_attachment" "main" {
  subnet_arns     = aws_subnet.cwan.*.arn
  core_network_id = aws_networkmanager_core_network.core.id
  vpc_arn         = aws_vpc.main.arn
  depends_on = [
    aws_networkmanager_core_network_policy_attachment.core
  ]
}

resource "aws_networkmanager_connect_attachment" "gre" {
  core_network_id         = aws_networkmanager_core_network.core.id
  transport_attachment_id = aws_networkmanager_vpc_attachment.main.id
  edge_location           = aws_networkmanager_vpc_attachment.main.edge_location
  options {
    protocol = "GRE"
  }
}

resource "awscc_networkmanager_connect_peer" "peer" {
  connect_attachment_id = aws_networkmanager_connect_attachment.gre.id
  inside_cidr_blocks = ["169.254.200.0/29"]
  peer_address = "10.1.2.1"
  bgp_options = {
    peer_asn = 65001
  }
}

output "bgp_info" {
  value = awscc_networkmanager_connect_peer.peer.configuration.bgp_configurations
}