docker:
  images:
    fluentd-aggregator:v0.12r1:
      state: present
      build: /opt/ops/docker/images/fluentd-aggregator
    fluentd-shipper:v0.12r1:
      state: present
      build: /opt/ops/docker/images/fluentd-shipper
    nginx-edge:1.13r1:
      state: present
      build: /opt/ops/docker/images/nginx-edge
