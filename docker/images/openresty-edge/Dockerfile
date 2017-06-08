FROM openresty/openresty:1.11.2.3-alpine-fat

RUN apk add --update openssl bash
RUN rm -rf /var/cache/apk/*

RUN luarocks install lua-resty-auto-ssl
RUN mkdir /etc/resty-auto-ssl
RUN chown nobody /etc/resty-auto-ssl

ADD  ssl        /usr/local/openresty/nginx/ssl
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
ADD  conf.d     /usr/local/openresty/nginx/conf/conf.d
