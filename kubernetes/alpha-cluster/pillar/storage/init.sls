storage:
  zpool_device: /dev/sdc
  containers:
    - name: fluentd-aggregator
      volumes:
        - name: buffer
          user: 1000
          group: 1000
          properties:
            quota: 4G
