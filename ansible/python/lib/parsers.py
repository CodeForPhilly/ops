class ComposeFileObject:
  def __init__(self, cfg_name, cfg_data):
    self.name   = cfg_name
    self.data   = cfg_data
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
