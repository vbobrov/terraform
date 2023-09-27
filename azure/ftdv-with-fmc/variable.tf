variable "location" {
  default = "eastus"
}

variable "fw_cidr" {
  default = "10.100.10.0/24"
}

# Number of zones for www
variable "www_zones" {
  default = 2
}

# Number of www VMs per zone
variable "www_per_zone" {
  default = 2
}

# Number of zones for FW
variable "fw_zones" {
  default = 2
}

# Number of FWs per zone
variable "fw_per_zone" {
  default = 1
}

# FW Health Probe
variable "health_port" {
  default = 12345
}

# Cluster Prefix
variable "cluster_prefix" {
  default = "ftd-cluster"
}

# Admin Password
variable "admin_password" {

}

# File location of the SSH private key locally. This key is used to ssh into firewalls. It is uploaded to jump host as well
variable "ssh_file" {
  default = "~/.ssh/aws-ssh-1.pem"
}

# Source IP address where ssh connection to the bastian host would initiate.
variable "ssh_sources" {
  default = ["100.100.100.0/24", "200.200.200.0/24"]
}

# Create DNS record for www external ip
variable "create_dns" {
  default = 0
}