# Install

common_install_firewalld:
  pkg.installed:
    - name: firewalld

# Configure

common_config_hostname:
  network.system:
    - hostname: {{ salt['grains.get']('id') }}

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

common_config_firewall_public:
  firewalld.present:
    - name: "''" # pass '' to the shell to specify default zone
    - interfaces:
      - eth0
    - services:
      - ssh
    - ports:
      - 19999/tcp

common_config_firewall_private:
  firewalld.present:
    - name: internal
    - sources:
      - 192.168.0.0/16

common_config_permit_private:
  cmd.run:
    - name: |
        firewall-cmd --permanent --zone=internal --set-target=ACCEPT
        firewall-cmd --zone=internal --set-target=ACCEPT
    - onchanges:
      - firewalld: common_config_firewall_private
