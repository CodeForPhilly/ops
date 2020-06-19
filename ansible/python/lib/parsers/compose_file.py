class ComposeFileObject:
  def __init__(self, cfg_name, cfg_data):
    self.name   = cfg_name
    self.data   = cfg_data if cfg_data else {}
    self.labels = self.data.get('labels')

  def label_get(self, label):

    if not self.labels:
      return None

    for k, v in self.labels.items():
      if k == label:
        return v

    return None

  def label_find(self, label_pfx):
    matching_labels = []

    if not self.labels:
      return matching_labels

    for k in self.labels.keys():
      if k.startswith(label_pfx):
        matching_labels.append(k)

    return matching_labels

  def routes(self):
    labels = self.label_find('civic-cloud.route')
    route_map = {}
    routes = []

    for label in labels:
      route_idx = label.rsplit('.', 1)[1]
      if route_idx == 'route':
        route_idx = '0'

      route_raw  = self.label_get(label)
      route_data = route_raw.rsplit(':', 1)
      route_addr = route_data[0]

      if len(route_data) > 1:
        route_tgt_port = route_data[1]
      else:
        route_tgt_port = self.data.get('expose', ['80'])[0]

      route_path_boundary = route_addr.find('/')

      if route_path_boundary >= 0:
        route_host = route_addr[:route_path_boundary]
        route_path = route_addr[route_path_boundary:]
      else:
        route_host = route_addr
        route_path = '/'

      route_map[route_idx] = {
        'host': route_host,
        'path': route_path,
        'binding': {
          'target': self.name,
          'port': route_tgt_port,
        }
      }

    for idx in sorted(route_map.keys()):
      routes.append(route_map[idx])

    return routes



class ComposeFileService(ComposeFileObject):

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
    img = self.label_get('civic-cloud.image')

    if img:
      return img

    return self.data.get('image')

  def container_entrypoint(self):
    return self.data.get('entrypoint')

  def container_command(self):
    return self.data.get('command')



class ComposeFileVolume(ComposeFileObject):

  def get_imports(self):
    import_labels = self.label_find('civic-cloud.import.')
    import_map    = {}
    imports       = []

    if len(import_labels) > 0:
      for key in import_labels:
        key_data    = key[len('civic-cloud.import.'):]
        import_data = key_data.split('.', 1)

        import_idx   = import_data[0]
        import_attr  = import_data[1] if len(import_data) > 1 else ''

        if import_idx == 'src':
          import_idx  = '0'
          import_attr = 'src'

        if import_idx == 'destroy':
          import_idx  = '0'
          import_attr = 'destroy'

        import_attr_val = self.label_get(key) if import_attr else ''

        if import_attr_val:
          if import_idx in import_map.keys():
            import_map[import_idx][import_attr] = import_attr_val
          else:
            import_map[import_idx] = { import_attr: import_attr_val }

    for idx in sorted(import_map.keys()):
      imports.append(import_map[idx])

    return imports

  def get_size(self):
    if len(self.label_find('civic-cloud.size',)) > 0:
      return self.label_get('civic-cloud.size')
    return ''
