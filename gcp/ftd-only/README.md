# Bulk FTD Deployment

This template will deploy multiple FTD firewalls following definition specified in variables

east4.tfvars and west3.tfvars show examples of variables

Variables are as follows:

- gcp_project - Specifies GCP project where to deploy
- machine_type - GCP machine type for FTD instances
- region - Region where to deploy the instances
- disk_encrypt_key - Self link for disk encryption KMS key
- ftd_service_account - Account ID for service account to be used for FTD instances
- ftd_image - Image to use for FTD instances
- fmc_ip - IP Address of FMC
- fmc_key - FMC Registration key
- admin_password - CLI admin password for FTD instances
- subnets - List of subnets where to connect FTD NICs. The subnets need to be specified in the same order as NICs on FTD.
- ftd_config - Lists firewalls to be added. At this point, this section only specifies the hostname and zone of the instances.

## Deployment

To deploy firewalls, adjust or create tfvars file and then run the following command

    terraform apply -var-file=west3.tfvars