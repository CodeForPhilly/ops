import sys
import json
import sqlite3
import ipaddress

inputs        = json.loads(sys.stdin.read())
db_path       = inputs['db_path']
subnet_pfxlen = int(inputs['subnet_pfxlen'])
supernets     = []

if __name__ == '__main__':
    db  = sqlite3.connect(db_path)
    dbc = db.cursor()

    dbc.execute('select value from node_domain where attribute = "network"')
    canonicalnet = ipaddress.IPv6Network(dbc.fetchone()[0])
    supernets.append(canonicalnet)

    dbc.execute('select prefix from node_subnets')
    subnets = map(lambda r: ipaddress.IPv6Network(r[0]), dbc.fetchall())

    for net in subnets:
        for block in supernets:
            if net.subnet_of(block):
                supernets.remove(block)
                supernets.extend(list(block.address_exclude(net)))
                break
    # order supernets smallest -> largest
    supernets.reverse()

    if len(supernets) == 0:
        sys.stderr.write(json.dumps({'msg': 'unable to allocate /{} subnet: network exhaustion'.format(subnet_pfxlen)}))
        sys.exit(1)

    i     = 0
    block = supernets[i]
    while block.prefixlen > subnet_pfxlen:
        i += 1
        try:
            block = supernets[i]
        except IndexError:
            sys.stderr.write(json.dumps({'msg': 'unable to allocate /{} subnet: no available supernets'.format(subnet_pfxlen)}))
            sys.exit(1)


    if block.prefixlen == subnet_pfxlen:
        subnet = block
    else:
        subnet = next(block.subnets(prefixlen_diff=subnet_pfxlen - block.prefixlen))

    sys.stdout.write(str(subnet))
    sys.exit(0)
