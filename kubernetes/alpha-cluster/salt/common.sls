# Install

common_install_firewalld:
  pkg.installed:
    - name: firewalld

# Configure

common_config_hostname:
  cmd.run:
    - name: hostnamectl set-hostname {{ salt['grains.get']('id') }}
    - unless:
      - test "$(hostname)" = "{{ salt['grains.get']('id') }}"

common_config_hosts:
  file.managed:
    - name: /etc/hosts
    - source: salt://files/hosts

common_config_authorized_keys:
  file.managed:
    - name: /root/.ssh/authorized_keys
    - source: salt://files/authorized_keys
    - makedirs: true
    - file_mode: 600
    - dir_mode: 700

common_config_sshd:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: '^PermitRootLogin yes'
    - repl: PermitRootLogin without-password

# Services

common_svc_sshd:
  service.running:
    - name: sshd
    - enable: true
    - watch:
      - file: common_config_sshd

common_svc_firewalld:
  service.running:
    - name: firewalld
    - enable: true

# Configure firewalld service

common_config_firewall_eth0:
  cmd.run:
    - name: firewallctl zone -p '' add interface eth0
    - unless:
      - firewallctl zone '' query interface eth0
    - onchanges_in:
      - cmd: common_config_firewall_reload

common_config_firewall_ssh:
  cmd.run:
    - name: firewallctl zone -p '' add service ssh
    - unless:
      - firewallctl zone '' query service ssh
    - onchanges_in:
      - cmd: common_config_firewall_reload

common_config_firewall_netdata:
  cmd.run:
    - name: firewallctl zone -p '' add port 19999/tcp
    - unless:
      - firewallctl zone '' query port 19999/tcp
    - onchanges_in:
      - cmd: common_config_firewall_reload

common_config_firewall_internal_source:
  cmd.run:
    - name: firewallctl zone -p internal add source 192.168.0.0/16
    - unless:
      - firewallctl zone internal query source 192.168.0.0/16
    - onchanges_in:
      - cmd: common_config_firewall_reload

common_config_internal_target:
  cmd.run:
    - name: firewall-cmd --permanent --zone=internal --set-target=ACCEPT
    - unless:
      - 'firewallctl info zone internal | grep "target: ACCEPT"'
    - onchanges_in:
      - cmd: common_config_firewall_reload

common_config_firewall_reload:
  cmd.run:
    - name: firewallctl reload
