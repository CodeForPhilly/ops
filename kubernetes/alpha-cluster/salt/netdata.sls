# Install

netdata_install_git:
  pkg.installed:
    - name: git-core

netdata_install_repo:
  module.run:
    - name: git.clone
    - cwd: /root/netdata
    - url: https://github.com/firehol/netdata.git
    - opts: '--depth=1'
    - unless:
      - stat /root/netdata

netdata_install_helper:
  file.managed:
    - name: /root/netdata/netdata-install-required.sh
    - source: https://raw.githubusercontent.com/firehol/netdata-demo-site/master/install-required-packages.sh
    - mode: 755
    - replace: false
    - skip_verify: true

netdata_install_deps:
  cmd.run:
    - name: /root/netdata/netdata-install-required.sh --non-interactive -i netdata
    - onchanges:
      - file: netdata_install_helper

netdata_install_main:
  cmd.run:
    - name: ./netdata-installer.sh --install /opt --dont-wait
    - cwd: /root/netdata
    - creates: /opt/netdata/etc/netdata/netdata.conf

# Service

netdata_svc_main:
  service.running:
    - name: netdata
    - enable: true
