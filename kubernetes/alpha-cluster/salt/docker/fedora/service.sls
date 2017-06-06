# Service

docker_service:
  service.running:
    - name: docker
    - enable: true
    - watch:
      - file: docker_config_sysconfig
