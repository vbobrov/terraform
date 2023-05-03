# Simple FTD and FMC deployment
This template can be use to quickly provision Secure Firewall Threat Defense (aka FTD) and Secure Firewall Management Center (aka FMC)

This template will provision the following:
- VPC
- 3 subnets: Management, Inside and Outside
- Internet Gateway
- Secure Firewall Threat Defense with Management, Diagnostic, Outside and Inside interfaces
- Elastic IP address assigned to Outside interface
- Secure Firewall Management Center with an assigned Public address
- Public SG allowing TCP/443 and UDP/443 to FTD's outside interface
- Management SG allowing all services from specified source IP addresses
- Internet Gateway
- Default route in the main routing table pointing to the Internet Gateway

The following variables are available:
- admin_password. If this variable is left as empty, a random password is generated.
- az. AWS Availability Zone where the FTD and FMC are deployed.
- ssh_key. Name of the SSH key pair in AWS that is used for FMC and FTD.
- ssh_sources. Contains a list of Public IP addresses where SSH and HTTPS will be allowed to FMC Public IP address