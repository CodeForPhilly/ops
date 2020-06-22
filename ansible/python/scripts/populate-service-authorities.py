import sys
import json

inputs = json.loads(sys.stdin.read())

project_name = inputs['project_name']
project_svcs = inputs['services']

outputs = []

if __name__ == '__main__':

    for svc in project_svcs:
        group_pfx = '{}.{}'.format(svc['name'], project_name)
        svc['authorities'] = [
            {'scope': 'global' ,  'name': '{}.service.domain'.format(group_pfx) },
            {'scope': 'node'   ,  'name': '{}.node.domain'.format(group_pfx)  },
        ]
        outputs.append(svc)

    sys.stdout.write(json.dumps(outputs))
    sys.exit(0)
