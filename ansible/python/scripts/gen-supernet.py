import sys
import json
import math
import random
import ipaddress

NULL_BYTE        = b'\x00'
CANONICAL_BYTE   = b'\xfd'
PFXLEN_MAX       = 128
PFXLEN_MIN       = 8
ADDRSPACE_NBYTES = 16

inputs  = json.loads(sys.stdin.read())
pfxlen  = int(inputs['pfxlen'])

if __name__ == '__main__':

    if pfxlen > PFXLEN_MAX:
        raise ValueError('Invalid supernet prefix: /{} is larger than max value of /{}'.format(pfxlen, PFXLEN_MAX))

    if pfxlen < PFXLEN_MIN:
        raise ValueError('Invalid supernet prefix: /{} is smaller than min value of /{}'.format(pfxlen, PFXLEN_MIN))

    if pfxlen == PFXLEN_MIN:
        supernet = ipaddress.IPv6Network((CANONICAL_BYTE + (NULL_BYTE * 15), PFXLEN_MIN))
        sys.stdout.write('{}'.format(supernet))
        sys.exit(0)

    pfxidlen        = pfxlen - PFXLEN_MIN
    pfxidlen_nbytes = math.ceil(pfxidlen / 8)
    pfxid           = random.getrandbits(pfxidlen).to_bytes(pfxidlen_nbytes, 'big')
    pfx             = CANONICAL_BYTE + pfxid
    pfx_fill        = NULL_BYTE * (ADDRSPACE_NBYTES - len(pfx))

    supernet_addr   = pfx + pfx_fill
    supernet        = ipaddress.IPv6Network(( supernet_addr, pfxlen ))

    sys.stdout.write(str(supernet))
    sys.exit(0)
