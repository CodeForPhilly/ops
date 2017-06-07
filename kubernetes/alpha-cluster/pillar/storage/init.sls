storage:
  zpool_device: /dev/sdc
  containers:
    - name: fluentd-aggregator
      volumes:
        - name: buffer
          quota: 4G
          user: 1000
          group: 1000
