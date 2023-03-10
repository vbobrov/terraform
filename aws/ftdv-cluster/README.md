# FTD Cluster Gateway Load Balancing

This template will provision resources to test Gateway Load Balancing with FTD firewalls configured as a cluster.
The topology that's created is shown following diagram.

Once provisioned, the clusters are added to CDO using ansible

Full walkthrough of this template is found here: https://www.securityccie.net/2023/03/06/deploying-cdo-managed-ftdv-cluster-in-aws/

As of version 7.3, FTD does not support clustering across multiple availability zones. This template will provision separate clusters in each availability zone. These clusters need to be individually added to FMC.

![Network Diagram](topology.jpg)


All files have comments in them describing the purpose of various resources