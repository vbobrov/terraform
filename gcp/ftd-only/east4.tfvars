#gcp_project= "project123"

machine_type = "c2-standard-16"

region = "us-east4"

ftd_image = "cisco-ftdv-7-2-5-208"

fmc_ip = "1.2.3.4"

fmc_key = "cisco123"

admin_password="Cisco123!"

subnets = [
    "firewall-untrusted-us-east4",
    "firewall-trusted-us-east4",
    "firewall-mgt-us-east4",
    "firewall-diag-us-east4",
    "firewall-reserved1-us-east4",
    "firewall-reserved2-us-east4",
    "firewall-reserved3-us-east4",
    "firewall-reserved4-us-east4"
]

ftd_config = {
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
