#!/bin/bash
echo "Configuración APISIX:"
cat /usr/local/apisix/conf/config.yaml

echo "Verificando conectividad con etcd:"
curl -v http://etcd:2379/version || echo "No se puede conectar a etcd"

echo "Iniciando APISIX..."
/usr/local/openresty/bin/openresty -p /usr/local/apisix -g 'daemon off;'
