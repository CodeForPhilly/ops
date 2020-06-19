import sys
import json
import parsers

compose_cfg = json.loads(sys.stdin.read())
volumes     = []

if __name__ == '__main__':

  if 'volumes' not in compose_cfg.keys():
    sys.stdout.write('[]')
    sys.exit(0)

  for compose_vol_name, compose_vol_data in compose_cfg['volumes'].items():

    compose_vol = parsers.ComposeFileObject(compose_vol_name, compose_vol_data)

    vol = {
      'name'     : compose_vol.name,
      'imports'  : compose_vol.collect_label_items('civic-cloud.import.', ('src', 'destroy')),
      'size'     : compose_vol.label_get('civic-cloud.size'),
      'bindings' : [],
    }

    if vol['size']:
      volumes.append(vol)

  sys.stdout.write(json.dumps(volumes))
  sys.exit(0)
