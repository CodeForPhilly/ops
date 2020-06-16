FROM haproxy:2.0

RUN     mkdir /var/empty
ADD     ./config /usr/local/etc/haproxy

CMD [                                              \
  "haproxy", "-W",                                 \
  "-f", "/usr/local/etc/haproxy/global.cfg",       \
  "-f", "/usr/local/etc/haproxy/resolvers.cfg",    \
  "-f", "/usr/local/etc/haproxy/frontend.cfg",     \
  "-f", "/usr/local/etc/haproxy/backends"          ]
