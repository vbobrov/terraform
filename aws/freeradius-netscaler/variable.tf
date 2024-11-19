variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "ssh_sources" {
  type    = list(any)
  default = ["100.100.100.0/24", "200.200.200.0/24"]
}

variable "radius_count" {
  default = 4
}

variable "adc_vip_cidr" {
  default = "10.2.0.0/16"
}

variable "ssh_key_name" {
  default = "aws-ssh-1"
}