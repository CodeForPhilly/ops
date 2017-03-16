# Variables

{% set zpool_name   = pillar['storage'].get('zpool_name', 'kubvols') %}
{% set zpool_device = pillar['storage']['zpool_device'] %}

# Install

storage_nfs_suse_install_zfs_repo:
  cmd.run:
    - name: |
        zypper addrepo obs://filesystems filesystems
        zypper --gpg-auto-import-keys refresh
    - creates: /etc/zypp/repos.d/filesystems.repo

storage_nfs_suse_install_zfs_modules:
  pkg.installed:
    - name: zfs-kmp-default

storage_nfs_suse_install_zfs_binaries:
  pkg.installed:
    - name: zfs

storage_nfs_suse_install_nfs:
  pkg.installed:
    - name: nfs-kernel-server

# Configure

storage_nfs_suse_configure_zfs_modules:
  kmod.present:
    - name: zfs
    - persist: true

storage_nfs_suse_configure_zpool:
  zpool.present:
    - name: {{ zpool_name }}
    - config:
        force: true
    - layout:
      - {{ zpool_device }}

# Services

storage_nfs_suse_svc_nfs:
    service.running:
      - name: nfs-server
      - enable: true

storage_nfs_suse_svc_zfs_enable:
  cmd.run:
    - name: systemctl enable zfs.target
    - unless:
      - systemctl is-enabled zfs.target

storage_nfs_suse_svc_zfs_run:
  cmd.run:
    - name: systemctl start zfs.target
    - unless:
      - systemctl status zfs.target
