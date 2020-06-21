import sys
import json
import math
import random
import ipaddress

inputs        = json.loads(sys.stdin.read())
db_path       = inputs['db_path']
subnet_pfxlen = int(inputs['subnet_pfxlen'])
supernet      = ipaddress.IPv6Network(inputs['supernet'])

if __name__ == '__main__':
    if subnet_pfxlen < supernet.prefixlen:
        raise ValueError('Invalid subnet prefix size of {} for supernet {}'.format(subnet_pfxlen, supernet))

    if subnet_pfxlen == supernet.prefixlen:
        sys.stdout.write(str(supernet))
        sys.exit(0)

    addrspace_nbytes    = math.ceil(supernet.max_prefixlen / 8)

    supernet_pfx_nbytes = math.ceil(supernet.prefixlen / 8)
    supernet_bytes      = int(supernet.network_address).to_bytes(addrspace_nbytes, 'big')
    supernetid          = supernet_bytes[:supernet_pfx_nbytes]

    subnetid_nbits      = subnet_pfxlen - supernet.prefixlen
    subnetid_nbytes     = math.ceil(subnetid_nbits / 8)
    subnetid            = random.getrandbits(subnetid_nbits).to_bytes(subnetid_nbytes, 'big')
    subnet_bytes        = supernetid + subnetid + ( b'\x00' * (addrspace_nbytes - (len(supernetid) + len(subnetid))) )

    subnet              = ipaddress.IPv6Network((subnet_bytes, subnet_pfxlen))

    sys.stdout.write(str(subnet))
    sys.exit(0)
