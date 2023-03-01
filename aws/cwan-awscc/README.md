When applying this template, the output includes two BGP peers

```
Outputs:

bgp_info = tolist([
  {
    "core_network_address" = "169.254.200.2"
    "core_network_asn" = 64512
    "peer_address" = "169.254.200.1"
    "peer_asn" = 65001
  },
  {
    "core_network_address" = "169.254.200.3"
    "core_network_asn" = 64512
    "peer_address" = "169.254.200.1"
    "peer_asn" = 65001
  },
])
```