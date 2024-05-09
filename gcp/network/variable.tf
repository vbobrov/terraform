variable "gcp_project" {}

variable "cidr" {
  default = "10.1.0.0/16"
}

variable "regions" {
  default = ["us-east4","us-west3"]
}

variable "subnets" {
  default = ["untrusted","trusted","mgt","diag","reserved1","reserved2","reserved3","reserved4"]
}

locals {
  all_subnets = setproduct(var.regions,var.subnets)
}