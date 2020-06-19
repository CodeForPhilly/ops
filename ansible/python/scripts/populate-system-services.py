import sys
import json
import parsers

inputs = json.loads(sys.stdin.read())

project_compose_cfg = inputs['project_compose_cfg']
project_services    = inputs['services']

outputs = []

if __name__ == '__main__':

    for svc in project_services:

        # Rewrite grid names
        svc['groups'] = [{ 'scope': 'system', 'name': '{}.system.domain'.format(svc['name']) }]
        svc['system'] = {}

        # Add port bindings
        compose_obj  = parsers.ComposeFileObject(svc['name'], project_compose_cfg['services'][svc['name']])
        system_ports = compose_obj.collect_label_maplist('civic-cloud.system.port.', ('node', 'svc'))

        for port in system_ports:
            if 'ports' in svc['system'].keys():
                svc['system']['ports'].append(port)
            else:
                svc['system']['ports'] = [ port ]

        outputs.append(svc)

    sys.stdout.write(json.dumps(outputs))
    sys.exit(0)
