base:
  '*':
    - ops_git
    - common
  kub*master*:
    - fedora_common
    - netdata
    - kubernetes.master
  kub*node*:
    - fedora_common
    - docker.fedora
    - kubernetes.node
    - docker.images
  kub*vol*:
    - suse_common
    - netdata
    - storage.nfs_suse
    - storage.volumes
