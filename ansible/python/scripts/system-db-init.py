import sys
import json
import random
import sqlite3
import ipaddress

inputs  = json.loads(sys.stdin.read())
db_path = inputs['db_path']

if __name__ == '__main__':
    node_pfx       = random.getrandbits(40).to_bytes(5, 'big')
    system_pfx     = random.getrandbits(40).to_bytes(5, 'big')

    node_net       = ipaddress.IPv6Network((
                        b'\xfd' + node_pfx   + (b'\x00' * 10),
                        48
                    ))

    system_net     = ipaddress.IPv6Network((
                        b'\xfd' + system_pfx + (b'\x00' * 10),
                        48
                    ))

    db             = sqlite3.connect(db_path)
    dbc            = db.cursor()

    dbc.executescript('''
        create table system_domain(
            attribute,
            value
        );
        create table node_domain(
            attribute,
            value
        );
        create table projects(
            name,
            attribute,
            value
        )
    ''')

    dbc.execute(
        'insert into system_domain(attribute, value) values (?, ?)',
        ('network', str(system_net))
    )

    dbc.executemany(
        'insert into node_domain(attribute, value) values (?, ?)',
        (
            ('id', node_pfx.hex()),
            ('network', str(node_net))
        )
    )

    db.commit()
    db.close()
    sys.exit(0)
