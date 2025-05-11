FROM apache/apisix:3.2.0-debian

# Crear configuración directamente en el Dockerfile
RUN echo 'etcd:\n  host:\n    - "http://etcd:2379"\n  prefix: "/apisix"\n  timeout: 30\n\napisix:\n  enable_admin: true\n  enable_admin_cors: true\n  admin_listen:\n    ip: 0.0.0.0\n    port: 9180\n\nhttp:\n  listen:\n    ip: 0.0.0.0\n    port: 9080\n\nnginx_config:\n  worker_processes: auto' > /usr/local/apisix/conf/config.yaml

# Verificar que la configuración se creó correctamente
RUN cat /usr/local/apisix/conf/config.yaml

# En lugar de usar un script personalizado, usamos un comando directo
CMD ["sh", "-c", "echo 'Configuración APISIX:' && cat /usr/local/apisix/conf/config.yaml && echo 'Verificando conectividad con etcd:' && curl -v http://etcd:2379/version && echo 'Iniciando APISIX...' && /usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'"]
