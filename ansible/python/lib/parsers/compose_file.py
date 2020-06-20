class ComposeFileObject:
  '''
  A dict wrapper for docker-compose file objects
  with convenience methods for inspecting & collecting
  object labels
  '''
  def __init__(self, cfg_name, cfg_data):
    self.name   = cfg_name
    self.data   = cfg_data if cfg_data else {}
    self.labels = self.data.get('labels')

  def get(self, key, default=None):
    return self.data.get(key, default)

  def __getitem__(self, item):
    return self.data[item]

  def label_get(self, label, default=None):
    '''
    Like get() but for labels
    '''

    if not self.labels:
      return default

    for k, v in self.labels.items():
      if k == label:
        return v

    return default

  def label_find(self, label_pfx):
    '''
    Returns a list of label keys which
    match the prefix label_pfx. Returns
    an empty list on no matches.
    '''
    matching_labels = []

    if not self.labels:
      return matching_labels

    for k in self.labels.keys():
      if k.startswith(label_pfx):
        matching_labels.append(k)

    return matching_labels

  def collect_label_list(self, label_pfx):
    '''
    Collect all labels with a given prefix
    and return a list of their values sorted
    by the suffix. Enables the implementation
    of list-like label objects in the form:

    label.item.0
    label.item.1

    The first item can also be specified in the
    form:

    label.item

    which will be treated as an alias for
    label.item.0
    '''
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

  def collect_label_maplist(self, label_pfx, attr_names):
    '''
    Collect all labels with a given prefix, treat the first
    member of the suffix as an index, and the second part of
    the suffix as an attribute name, as defined in attr_names.
    Return a list of mappings of the collected attributes for
    each item. This allows implementing lists of maps in labels
    by using the form:

    label.item.0.foo
    label.item.0.bar
    label.item.1.foo
    label.item.1.bar

    Where 'foo' and 'bar' are specified in the attr_names list.
    Item attributes not specified in attr_names are not collected.
    The first item can also be specified in the form:

    label.item.foo
    label.item.bar

    which will be treated as an alias of:

    label.item.0.foo
    label.item.0.bar
    '''
    item_labels = self.label_find(label_pfx)
    item_map    = {}
    items       = []

    if len(item_labels) > 0:
      for key in item_labels:
        key_data    = key[len(label_pfx):]
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
