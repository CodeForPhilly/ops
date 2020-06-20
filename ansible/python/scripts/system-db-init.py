import sys
import json
import random
import sqlite3

inputs  = json.loads(sys.stdin.read())
db_path = inputs['db_path']

def hex2ip6(pfx, pfxsz):
    ip6      = ''
    chunksz  = 4
    i        = 0
    szunread = len(pfx[i:])

    while i < len(pfx):

        if szunread >= chunksz:
            ip6 += pfx[i:i + chunksz]
        else:
            ip6 += pfx[i:]

        i        += chunksz

        if i < len(pfx):
            szunread = len(pfx[i:])
        else:
            szunread = 0

        if szunread > 0:
            ip6 += ':'
        else:
            ip6 += '::/{}'.format(pfxsz)

    return ip6


if __name__ == '__main__':
    node_id       = random.getrandbits(40).to_bytes(5, 'big').hex()
    system_id     = random.getrandbits(40).to_bytes(5, 'big').hex()
    node_v6_pfx   = hex2ip6('fd' + node_id, '48')
    system_v6_pfx = hex2ip6('fd' + system_id, '48')

    sys.stderr.write('{}\n'.format(node_id))
    sys.stderr.write('{}\n'.format(node_v6_pfx))

    db            = sqlite3.connect(db_path)
    dbc           = db.cursor()

    dbc.executescript('''
        create table system_domain(
            attribute,
            value
        );
        create table node_domain(
            attribute,
            value
        );
    ''')

    dbc.execute(
        'insert into system_domain(attribute, value) values (?, ?)',
        ('network', system_v6_pfx)
    )

    dbc.executemany(
        'insert into node_domain(attribute, value) values (?, ?)',
        (
            ('id', node_id),
            ('network', node_v6_pfx)
        )
    )

    db.commit()
    db.close()
    sys.exit(0)
