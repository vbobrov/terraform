#gcp_project= "project123"

machine_type = "c2-standard-16"

region = "us-west3"

ftd_image = "cisco-ftdv-7-2-5-208"

fmc_ip = "1.2.3.4"

fmc_key = "cisco123"

admin_password="Cisco123!"

subnets = [
    "firewall-untrusted-us-west3",
    "firewall-trusted-us-west3",
    "firewall-mgt-us-west3",
    "firewall-diag-us-west3",
    "firewall-reserved1-us-west3",
    "firewall-reserved2-us-west3",
    "firewall-reserved3-us-west3",
    "firewall-reserved4-us-west3"
]

ftd_config = {
    "ftd-west-1": {
        "zone": "a"
    },
    "ftd-west-2": {
        "zone": "a"
    }
    "ftd-west-3": {
        "zone": "b"
    }
    "ftd-west-4": {
        "zone": "c"
    }
}
