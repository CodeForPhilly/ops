# Configure

fedoracommon_config_selinux_permissive_persist:
  file.replace:
    - name: /etc/selinux/config
    - pattern: '^.*SELINUX=enforcing'
    - repl: SELINUX=permissive

fedoracommon_config_selinux_permissive_runtime:
  selinux.mode:
    - name: permissive

fedoracommon_config_disallow_cockpit:
  module.run:
    - name: firewalld.remove_service
    - service: cockpit
    - zone: ''
    - onlyif:
      - firewallctl zone '' query service cockpit

# Services

fedoracommon_service_cockpit:
  service.dead:
    - name: cockpit
    - enable: false
