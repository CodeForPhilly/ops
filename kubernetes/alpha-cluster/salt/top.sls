base:
  '*':
    - common
  kub*master*:
    - fedora_common
    - netdata
    - kubernetes.master
  kub*node*:
    - fedora_common
    - kubernetes.node
  kub*vol*:
    - suse_common
    - netdata
    - storage.nfs_suse
    - storage.volumes
