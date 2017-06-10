docker:
  images:
    fluentd-aggregator:v0.12r2:
      state: present
      build: /opt/ops/docker/images/fluentd-aggregator
    fluentd-collector:v0.12r1:
      state: present
      build: /opt/ops/docker/images/fluentd-collector
    nginx-edge:1.13r1:
      state: present
      build: /opt/ops/docker/images/nginx-edge
    postgres-shared:9.6r1:
      state: present
      build: /opt/ops/docker/images/postgres-shared
    openresty-edge:1.11.2.3r1:
      state: present
      build: /opt/ops/docker/images/openresty-edge
