import sys
import json
import parsers

class ComposeFileService(parsers.ComposeFileObject):

  def get_ports(self):
    return self.data.get('expose', [])

  def get_startup(self):
    startup = self.label_get('civic-cloud.startup')

    if startup is None:
      return True

    if startup:
      return True
    else:
      return False

  def container_image(self):
    return self.data.get('image')

  def container_entrypoint(self):
    return self.data.get('entrypoint')

  def container_command(self):
    return self.data.get('command')


compose_cfg = json.loads(sys.stdin.read())
services    = []

if __name__ == '__main__':

  if 'services' not in compose_cfg.keys():
    sys.stdout.write('[]')
    sys.exit(0)

  for compose_svc_name, compose_svc_data in compose_cfg['services'].items():

    if not compose_svc_data:
      compose_svc_data = {}
    compose_svc = ComposeFileService(compose_svc_name, compose_svc_data)

    svc = {
      'name'            : compose_svc.name,
      'ports'           : compose_svc.get_ports(),
      'startup'         : compose_svc.get_startup(),
      'container_opts'  : {}
    }

    container_image      = compose_svc.container_image()
    container_entrypoint = compose_svc.container_entrypoint()
    container_command    = compose_svc.container_command()

    if container_image is not None:
      svc['container_opts']['image'] = container_image

    if container_entrypoint is not None:
      svc['container_opts']['entrypoint'] = container_entrypoint

    if container_command is not None:
      svc['container_opts']['command'] = container_command

    services.append(svc)

  sys.stdout.write(json.dumps(services))
  sys.exit(0)
