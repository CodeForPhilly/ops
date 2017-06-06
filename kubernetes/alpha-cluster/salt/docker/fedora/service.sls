# Service

docker_service:
  service.running:
    - name: docker
    - enabled: true
    - watch:
      - file: docker_config_sysconfig
