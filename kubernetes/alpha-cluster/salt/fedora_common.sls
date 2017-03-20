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
  cmd.run:
    - name: firewallctl zone -p '' remove service cockpit
    - onlyif:
      - firewallctl zone '' query service cockpit
    - onchanges_in:
      - cmd: common_config_firewall_reload

# Services

fedoracommon_service_cockpit:
  service.dead:
    - name: cockpit
    - enable: false
