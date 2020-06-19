class ComposeFileObject:
  def __init__(self, cfg_name, cfg_data):
    self.name   = cfg_name
    self.data   = cfg_data if cfg_data else {}
    self.labels = self.data.get('labels')

  def get(self, key, default=None):
    return self.data.get(key, default)

  def __getitem__(self, item):
    return self.data[item]

  def label_get(self, label, default=None):

    if not self.labels:
      return default

    for k, v in self.labels.items():
      if k == label:
        return v

    return default

  def label_find(self, label_pfx):
    matching_labels = []

    if not self.labels:
      return matching_labels

    for k in self.labels.keys():
      if k.startswith(label_pfx):
        matching_labels.append(k)

    return matching_labels

  def collect_label_list(self, label_pfx):
    labels = self.label_find(label_pfx)
    item_map = {}
    items = []

    for label in labels:
      item_idx = label.rsplit('.', 1)[1]

      if item_idx == label_pfx.rsplit('.', 1)[-1]:
        item_idx = '0'

      item_map[item_idx] = self.label_get(label)

    for idx in sorted(item_map.keys()):
      items.append(item_map[idx])

    return items

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

  def routes(self):

    routes     = []
    routes_raw = self.collect_label_list('civic-cloud.route')

    for raw in routes_raw:
      route_tokens = raw.rsplit(':', 1)
      route_addr   = route_tokens[0]

      if len(route_tokens) > 1:
        route_tgt_port = route_tokens[1]
      else:
        route_tgt_port = self.data.get('expose', ['80'])[0]

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
          'target': self.name,
          'port': route_tgt_port,
        }
      })

    return routes
