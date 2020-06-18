import sys
import json

compose_cfg = json.loads(sys.stdin.read())
volumes     = []

for cfg_volname, cfg_vol in compose_cfg['volumes'].items():
  vol = {}
  vol['name'] = cfg_volname
  volumes.append(vol)

sys.stdout.write(json.dumps(volumes))
sys.exit(0)
