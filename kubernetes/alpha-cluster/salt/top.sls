base:
  '*':
    - common
  kub*master*:
    - fedora_common
    - netdata
  kub*node*:
    - fedora_common
    - kubernetes.node
  kub*vol*:
    - suse_common
    - netdata
    - storage.nfs_suse
