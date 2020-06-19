import sys
import json
import parsers

compose_cfg = json.loads(sys.stdin.read())
services    = []

if __name__ == '__main__':

  if 'services' not in compose_cfg.keys():
    sys.stdout.write('[]')
    sys.exit(0)

  for compose_svc_name, compose_svc_data in compose_cfg['services'].items():

    compose_svc          = parsers.ComposeFileObject(compose_svc_name, compose_svc_data)
    svc_startup          = compose_svc.label_get('civic-cloud.startup')
    container_image      = compose_svc.label_get('civic-cloud.image', compose_svc.get('image'))
    container_entrypoint = compose_svc.get('entrypoint')
    container_command    = compose_svc.get('command')


    svc = {
      'name'            : compose_svc.name,
      'ports'           : compose_svc.get('expose', []),
      'startup'         : svc_startup if svc_startup is not None else True,
      'container_opts'  : {}
    }

    if container_image is not None:
      svc['container_opts']['image'] = container_image

    if container_entrypoint is not None:
      svc['container_opts']['entrypoint'] = container_entrypoint

    if container_command is not None:
      svc['container_opts']['command'] = container_command

    services.append(svc)

  sys.stdout.write(json.dumps(services))
  sys.exit(0)
