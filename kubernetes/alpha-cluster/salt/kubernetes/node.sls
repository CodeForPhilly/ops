# Configure

kubernetes_node_config_docker:
  file.managed:
    - name: /etc/sysconfig/docker
    - source: salt://files/sysconfig-docker
