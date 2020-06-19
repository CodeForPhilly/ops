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

  def collect_label_items(self, label_pfx, attr_names):
    item_labels = self.label_find(label_pfx)
    item_map    = {}
    items       = []

    if len(item_labels) > 0:
      for key in item_labels:
        key_data     = key[len(label_pfx):]
        key_tokens  = key_data.split('.', 1)

        item_idx   = key_tokens[0]
        item_attr  = key_tokens[1] if len(key_tokens) > 1 else ''

        for name in attr_names:
          if item_idx == name:
            item_idx  = '0'
            item_attr = name

        item_attr_val = self.label_get(key) if item_attr else ''

        if item_attr not in attr_names: continue

        if item_idx in item_map.keys():
          item_map[item_idx][item_attr] = item_attr_val
        else:
          item_map[item_idx] = { item_attr: item_attr_val }

      for idx in sorted(item_map.keys()):
        items.append(item_map[idx])

    return items



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

  def system_ports(self):
    return self.collect_label_items('civic-cloud.system.port.', ('node', 'service'))



class ComposeFileVolume(ComposeFileObject):

  def get_imports(self):
    return self.collect_label_items('civic-cloud.import.', ('src', 'destroy'))

  def get_size(self):
    if len(self.label_find('civic-cloud.size',)) > 0:
      return self.label_get('civic-cloud.size')
    return ''
