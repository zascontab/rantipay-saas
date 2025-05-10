FROM apache/apisix:3.2.0-debian

COPY config.yaml /usr/local/apisix/conf/config.yaml
ENV ETCD_HOST=etcd
ENV ETCD_PORT=2379
ENV APISIX_STAND_ALONE=false
