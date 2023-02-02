variable "vpc_cidr" {
  default = "10.1.0.0/16"
}

variable "ssh_sources" {
  default = ["100.100.100.0/24", "200.200.200.0/24"]
}

variable "ise_count" {
  default = 2
}

variable "f5_vip_cidr" {
  default = "10.2.0.0/16"
}

variable "root_ca_file" {
  default = ".demo-ca-root.cer"
}

variable "system_ca_file" {
  default = ".aws.ciscodemo.net.cer"
}

variable "system_key_file" {
  default = ".aws.ciscodemo.net.key"
}