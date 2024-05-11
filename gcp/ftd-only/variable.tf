variable "gcp_project" {}

variable "machine_type" {
  description = "Machine Type for FTD Instances"
}

variable "region" {
  description = "Region where to deploy instances"
}

variable "disk_encrypt_key" {
  description = "Self-link for KMS Key to encrypt FTD disk"
}

variable "ftd_service_account" {
  description = "Service Account for FTD Instances"
}

# Run the following command to get image names: gcloud compute images list --project cisco-public --no-standard-image
variable "ftd_image" {
  description = "FTD Image/Version"
}

variable "fmc_ip" {
  description = "FMC IP Address"
}

variable "fmc_key" {
  description = "FMC Registration Key"
  sensitive   = true
}

variable "admin_password" {
  description = "FTD CLI Admin Password"
  sensitive   = true
}

variable "subnets" {
  description = "List of subnets for FTD NICs in the same order as Network Interfaces"
  type        = list(string)
}

variable "ftd_config" {
  description = "List of FTD Firewalls"
}