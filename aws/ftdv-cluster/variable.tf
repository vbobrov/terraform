# AZ list where Apps are deployed
variable "app_azs" {
  default = ["us-east-1a", "us-east-1b"]
}

# AZ list where Firewall resources are deployed
# Due to limitation of FTD 7.3, the entire cluster has to be in the same AZ
variable "fw_azs" {
  default = ["us-east-1a","us-east-1b"]
}

# GWLB AZs
variable "inet_azs" {
  default = ["us-east-1a","us-east-1b"]
}

# Number of firewalls in each AZ
variable "fw_per_az" {
  default = 2
}

variable "ssh_key" {
  default = "aws-ssh-1"
}

# Source IP address where ssh connection to the bastian host would initiate.
variable "ssh_sources" {
  default = ["100.100.100.0/24","200.200.200.0/24"]
}
