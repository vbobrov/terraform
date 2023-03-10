# AZ list where Apps are deployed
variable "app_azs" {
  default = ["us-east-1a", "us-east-1b"]
}

# AZ list where Firewall resources are deployed
# Due to limitation of FTD 7.3, the entire cluster has to be in the same AZ
variable "fw_azs" {
  default = ["us-east-1a", "us-east-1b"]
}

# GWLB AZs
variable "inet_azs" {
  default = ["us-east-1a", "us-east-1b"]
}

# Number of firewalls in each AZ
variable "fw_per_az" {
  default = 2
}

# Cluster Prefix
variable "cluster_prefix" {
  default = "ftd-cluster"
}

# Name of the SSH key in AWS
variable "ssh_key" {
  default = "aws-ssh-1"
}

# File location of the SSH private key locally. This key is used to ssh into firewalls. It is uploaded to jump host as well
variable "ssh_file" {
  default = "~/.ssh/aws-ssh-1.pem"
}

# Source IP address where ssh connection to the bastian host would initiate.
variable "ssh_sources" {
  default = ["100.100.100.0/24", "200.200.200.0/24"]
}

# CDO API Token
variable "cdo_token" {

}

# ACP Policy to apply to the firewalls
variable "acp_policy" {
  default = "AWS-Cluster"
}