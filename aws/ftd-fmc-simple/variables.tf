# Admin password. If left as blank, a random passwod would be generated
variable "admin_password" {
  default = ""
}

# Availability zone for the resources
variable "az" {
  default = "us-east-1a"
}

# Source IP address where ssh connection to the bastian host would initiate.
variable "ssh_sources" {
  default = ["100.100.100.0/24", "200.200.200.0/24"]
}

# Name of the SSH key in AWS
variable "ssh_key" {
  
}
