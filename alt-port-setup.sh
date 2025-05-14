#!/bin/bash

# Script para crear un servicio mínimo en puerto alternativo (8888)
# y configurar APISIX con múltiples opciones de conectividad

echo "🚀 Configurando servidor mínimo en puerto alternativo..."

PROJECT_ROOT=~/developer/projects/rantipay/wankarlab/rantipay-saas/kit
NEW_PORT=8888

# Detener cualquier servicio existente
echo "🛑 Deteniendo servicios existentes..."
kill $(cat $PROJECT_ROOT/logs/user-minimal.pid) 2>/dev/null || true

# Modificar el servidor para usar el nuevo puerto
cd $PROJECT_ROOT/minimal
sed -i "s/--port=8000/--port=$NEW_PORT/g" $PROJECT_ROOT/minimal/server.go

# Recompilar el servidor
echo "🔨 Recompilando servidor para puerto $NEW_PORT..."
go build -o minimal-server server.go

# Iniciar el servidor en el nuevo puerto
echo "🚀 Iniciando servidor en puerto $NEW_PORT..."
export SERVICE_NAME="user-minimal"
nohup ./minimal-server --port=$NEW_PORT > $PROJECT_ROOT/logs/user-minimal.log 2>&1 &
echo $! > $PROJECT_ROOT/logs/user-minimal.pid

echo "✅ Servidor iniciado en puerto $NEW_PORT (PID: $(cat $PROJECT_ROOT/logs/user-minimal.pid))"

# Obtener la IP de la máquina
INTERNAL_IP=$(hostname -I | awk '{print $1}')
echo "🔍 IP interna: $INTERNAL_IP"

# Configurar múltiples rutas en APISIX para probar diferentes opciones
echo "🔄 Configurando múltiples rutas en APISIX..."

# Opción 1: Usando 127.0.0.1
curl -s http://localhost:9280/apisix/admin/routes/user-local -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"/user-local/*\",
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"127.0.0.1:$NEW_PORT\": 1
    }
  }
}"

# Opción 2: Usando la IP interna
curl -s http://localhost:9280/apisix/admin/routes/user-ip -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"/user-ip/*\",
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"$INTERNAL_IP:$NEW_PORT\": 1
    }
  }
}"

# Opción 3: Usando host.docker.internal
curl -s http://localhost:9280/apisix/admin/routes/user-docker -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"/user-docker/*\",
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"host.docker.internal:$NEW_PORT\": 1
    }
  }
}"

# Probar acceso local
echo "🔍 Verificando acceso local..."
if curl -s http://localhost:$NEW_PORT > /dev/null; then
    echo "✅ Confirmado: El servicio responde localmente en http://localhost:$NEW_PORT"
else
    echo "❌ Error: El servicio no responde localmente."
fi

# Configurar un túnel socat en un puerto diferente
echo "🔄 Configurando túnel socat para conectividad desde APISIX..."
docker rm -f socat-tunnel 2>/dev/null || true
docker run -d --name socat-tunnel --network=kit_default -p $NEW_PORT:$NEW_PORT alpine/socat tcp-listen:$NEW_PORT,fork,reuseaddr tcp-connect:host.docker.internal:$NEW_PORT

echo ""
echo "🌟 Configuración completada con múltiples opciones de acceso"
echo "=========================================================="
echo "📌 Acceso directo: http://localhost:$NEW_PORT"
echo ""
echo "📌 Opciones de acceso vía APISIX (prueba cada una):"
echo "   1. http://localhost/user-local"
echo "   2. http://localhost/user-ip"
echo "   3. http://localhost/user-docker"
echo ""
echo "📝 Logs del servidor:"
echo "   tail -f $PROJECT_ROOT/logs/user-minimal.log"
echo ""
echo "📝 Logs de APISIX:"
echo "   docker logs kit-apisix-1"
echo "=========================================================="