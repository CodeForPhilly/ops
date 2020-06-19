import sys
import json

inputs = json.loads(sys.stdin.read())

project_compose_cfg = inputs['project_compose_cfg']
project_volumes     = inputs['volumes']

outputs = []

if __name__ == '__main__':

    for vol in project_volumes:
        for svc_name, svc_data in project_compose_cfg.get('services', {}).items():
            if 'volumes' in svc_data.keys():
                for binding in svc_data['volumes']:

                    if hasattr(binding, 'get'):
                        binding_vol_name       = binding.get('source')
                        binding_vol_mountpoint = binding.get('target')
                    else:
                        binding_tokens = binding.split(':')
                        if len(binding_tokens) < 2:
                            continue
                        binding_vol_name       = binding_tokens[0]
                        binding_vol_mountpoint = binding_tokens[1]

                    if binding_vol_name == vol['name']:
                        vol['bindings'].append({ 'service': svc_name, 'mountpoint': binding_vol_mountpoint })

        outputs.append(vol)

    sys.stdout.write(json.dumps(outputs))
    sys.exit(0)
