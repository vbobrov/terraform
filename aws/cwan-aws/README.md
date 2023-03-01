When applying this template, the output only includes the first BGP peer

```
Outputs:

bgp_info = tolist([
  {
    "core_network_address" = "169.254.200.2"
    "core_network_asn" = 64512
    "peer_address" = "169.254.200.1"
    "peer_asn" = 65001
  },
])
```