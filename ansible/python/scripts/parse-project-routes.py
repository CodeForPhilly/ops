import sys
import json
import parsers.compose_file

compose_cfg = json.loads(sys.stdin.read())
routes      = []

if __name__ == '__main__':

  if 'services' in compose_cfg.keys():
    for compose_obj_name, compose_obj_data in compose_cfg['services'].items():

      compose_obj = parsers.compose_file.ComposeFileObject(compose_obj_name, compose_obj_data)
      svc_routes  = compose_obj.routes()

      for route in svc_routes:
        route['binding']['type'] = 'service'
        routes.append(route)

  if 'volumes' in compose_cfg.keys():
    for compose_obj_name, compose_obj_data in compose_cfg['volumes'].items():

        compose_obj = parsers.compose_file.ComposeFileObject(compose_obj_name, compose_obj_data)
        vol_routes  = compose_obj.routes()

        for route in vol_routes:
          route['binding']['type'] = 'volume'
          routes.append(route)

  sys.stdout.write(json.dumps(routes))
  sys.exit(0)
