import sys
import json
import parsers

compose_cfg = json.loads(sys.stdin.read())
routes      = []

if __name__ == '__main__':

  for section_name, section_objs in compose_cfg.items():
    if section_name in ('services', 'volumes'):
      for compose_obj_name, compose_obj_data in section_objs.items():

        compose_obj = parsers.ComposeFileObject(compose_obj_name, compose_obj_data)
        routes_raw  = compose_obj.collect_label_list('civic-cloud.route')

        for raw in routes_raw:
          route_tokens = raw.rsplit(':', 1)
          route_addr   = route_tokens[0]

          if len(route_tokens) > 1:
            route_tgt_port = route_tokens[1]
          else:
            route_tgt_port = compose_obj.get('expose', [None])[0]

          route_path_boundary = route_addr.find('/')

          if route_path_boundary >= 0:
            route_host = route_addr[:route_path_boundary]
            route_path = route_addr[route_path_boundary:]
          else:
            route_host = route_addr
            route_path = '/'

          routes.append({
            'host': route_host,
            'path': route_path,
            'binding': {
              'target': compose_obj.name,
              'port': route_tgt_port if route_tgt_port is not None else '80',
              'type': 'service' if section_name == 'services' else 'volume'
            }
          })

  sys.stdout.write(json.dumps(routes))
  sys.exit(0)
