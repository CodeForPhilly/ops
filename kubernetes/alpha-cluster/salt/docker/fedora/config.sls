# Configure

docker_config_sysconfig:
  file.managed:
    - name: /etc/sysconfig/docker
    - source: salt://files/sysconfig-docker
