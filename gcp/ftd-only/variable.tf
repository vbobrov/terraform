variable "gcp_project" {}

variable "machine_type" {
  description = "Machine Type for FTD Instances"
  default = "c2-standard-8"
}

variable "region" {
  description = "Region where to deploy instances"
  default = "us-east4"
}

# Run the following command to get image names: gcloud compute images list --project cisco-public --no-standard-image
variable "ftd_image" {
  description = "FTD Image/Version"
  default = "cisco-ftdv-7-2-5-208"
}


variable "fmc_ip" {
  description = "FMC IP Address"
  default = "1.2.3.4"
}

variable "fmc_key" {
  description = "FMC Registration Key"
  default = "cisco123"
}

variable "admin_password" {
  description = "FTD CLI Admin Password"
  sensitive = true
  default = "Cisco123!"
}

variable "subnets" {
  default = [
    "firewall-untrusted-us-east4",
    "firewall-trusted-us-east4",
    "firewall-mgt-us-east4",
    "firewall-diag-us-east4",
    "firewall-reserved1-us-east4",
    "firewall-reserved2-us-east4",
    "firewall-reserved3-us-east4",
    "firewall-reserved4-us-east4"
  ]
}

variable "ftd_config" {
  default = {
    "ftd-east-1": {
      "zone": "a"
    },
    "ftd-east-2": {
      "zone": "a"
    }
    "ftd-east-3": {
      "zone": "b"
    }
    "ftd-east-4": {
      "zone": "c"
    }
  }
}