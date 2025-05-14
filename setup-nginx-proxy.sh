#!/bin/bash

# Este script configura un servidor proxy NGINX dentro de Docker
# para resolver los problemas de conectividad entre APISIX y tu servidor local

echo "🚀 Configurando solución definitiva de conectividad..."

PROJECT_ROOT=~/developer/projects/rantipay/wankarlab/rantipay-saas/kit
LOCAL_PORT=8888
DOCKER_PORT=8889

# Verificar que el servidor local esté funcionando
if ! curl -s http://localhost:$LOCAL_PORT > /dev/null; then
    echo "❌ Error: El servidor no está respondiendo en http://localhost:$LOCAL_PORT"
    echo "   Por favor, asegúrate de que tu servidor local esté funcionando primero."
    exit 1
fi

echo "✅ Servidor local funcionando correctamente en puerto $LOCAL_PORT"

# Obtener la IP de la máquina
HOST_IP=$(hostname -I | awk '{print $1}')
echo "🔍 IP de la máquina host: $HOST_IP"

# Detener cualquier contenedor existente
echo "🧹 Limpiando contenedores existentes..."
docker rm -f nginx-bridge socat-tunnel 2>/dev/null || true

# Configurar un servidor NGINX como proxy
echo "🔄 Creando configuración de NGINX..."
mkdir -p $PROJECT_ROOT/nginx-proxy
cat > $PROJECT_ROOT/nginx-proxy/nginx.conf << EOF
events {
    worker_connections 1024;
}

http {
    server {
        listen 80;
        
        location / {
            proxy_pass http://$HOST_IP:$LOCAL_PORT;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;
            
            # Debug headers
            add_header X-Debug-Host "$HOST_IP:$LOCAL_PORT" always;
            add_header X-Debug-Remote \$remote_addr always;
        }
    }
}
EOF

# Iniciar contenedor NGINX con la configuración
echo "🚀 Iniciando servidor NGINX proxy..."
docker run -d --name nginx-bridge \
    --network kit_default \
    -p $DOCKER_PORT:80 \
    -v $PROJECT_ROOT/nginx-proxy/nginx.conf:/etc/nginx/nginx.conf:ro \
    nginx:alpine

# Verificar que el proxy esté funcionando
echo "⏳ Esperando a que el proxy inicie..."
sleep 3

# Verificar que el proxy NGINX esté funcionando
NGINX_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx-bridge)
echo "🔍 IP del proxy NGINX: $NGINX_IP"

# Configurar APISIX para usar el proxy NGINX
echo "🔄 Configurando APISIX para usar el proxy NGINX..."
curl -s http://localhost:9280/apisix/admin/routes/user-proxy -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"/user/*\",
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"$NGINX_IP:80\": 1
    }
  }
}"

# Información para el usuario
echo ""
echo "🌟 Solución de conectividad configurada"
echo "========================================"
echo "📌 Hemos configurado un proxy NGINX dentro de la red de Docker para"
echo "   redirigir las solicitudes desde APISIX a tu servidor local."
echo ""
echo "📌 El flujo ahora es:"
echo "   APISIX → Proxy NGINX ($NGINX_IP:80) → Tu servidor local ($HOST_IP:$LOCAL_PORT)"
echo ""
echo "📌 Prueba accediendo a:"
echo "   1. Servidor local directo: http://localhost:$LOCAL_PORT"
echo "   2. A través de APISIX: http://localhost/user"
echo ""
echo "📝 Para ver los logs del proxy:"
echo "   docker logs nginx-bridge"
echo ""
echo "🛑 Para detener el proxy:"
echo "   docker stop nginx-bridge"
echo "========================================"

# Probar acceso al proxy
echo "🔍 Probando acceso al proxy..."
PROXY_URL="http://localhost:$DOCKER_PORT"
PROXY_RESPONSE=$(curl -s $PROXY_URL)

if [ -n "$PROXY_RESPONSE" ]; then
    echo "✅ Proxy funcionando correctamente. Respuesta:"
    echo "$PROXY_RESPONSE"
else
    echo "❌ Error: No se pudo conectar al proxy en $PROXY_URL"
fi