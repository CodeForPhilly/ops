docker:
  images:
    fluentd-aggregator:v0.12r1:
      state: present
      build: /opt/ops/docker/images/fluentd-aggregator
    fluentd-collector:v0.12r1:
      state: present
      build: /opt/ops/docker/images/fluentd-collector
    nginx-edge:1.13r1:
      state: present
      build: /opt/ops/docker/images/nginx-edge
