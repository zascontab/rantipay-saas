#!/bin/bash

# Este script configura una ruta con alta prioridad y un path más específico en APISIX

echo "🔄 Configurando ruta de alta prioridad en APISIX..."

# Verificar que el microservidor siga funcionando
SERVER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' user-microserver)
if [ -z "$SERVER_IP" ]; then
    echo "❌ Error: No se encontró el contenedor user-microserver"
    echo "   Por favor, ejecuta primero el script docker-go-server.sh"
    exit 1
fi

echo "✅ Microservidor encontrado en IP: $SERVER_IP"

# Verificar que el servidor responde internamente
RESPONSE=$(docker exec kit-apisix-1 curl -s http://$SERVER_IP)
if [ -z "$RESPONSE" ]; then
    echo "❌ Error: El servidor no responde desde APISIX"
else
    echo "✅ El servidor responde correctamente dentro de Docker:"
    echo "$RESPONSE"
fi

# Crear una ruta muy específica y con alta prioridad
echo "🔄 Creando ruta específica con alta prioridad..."
ROUTE_PATH="/api/microservice"

curl -s http://localhost:9280/apisix/admin/routes/micro-api -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"$ROUTE_PATH/*\",
  \"priority\": 9999,
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"$SERVER_IP:80\": 1
    }
  }
}"

# Configurar un plugin de CORS para asegurar que las respuestas pasen correctamente
echo "🔄 Configurando plugin CORS para la ruta..."
curl -s http://localhost:9280/apisix/admin/routes/micro-api -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PATCH -d "{
  \"plugins\": {
    \"cors\": {
      \"allow_origins\": \"*\",
      \"allow_methods\": \"GET,POST,PUT,DELETE,PATCH,OPTIONS\",
      \"allow_headers\": \"*\",
      \"expose_headers\": \"*\"
    }
  }
}"

# Mostrar todas las rutas configuradas
echo "🔄 Listando todas las rutas configuradas en APISIX..."
curl -s http://localhost:9280/apisix/admin/routes -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" | grep -o '"id":"[^"]*"' | sort

echo ""
echo "🌟 Ruta de alta prioridad configurada"
echo "========================================"
echo "📌 Nueva ruta configurada:"
echo "   http://localhost$ROUTE_PATH"
echo ""
echo "📌 Prueba usando curl para verificar la respuesta:"
echo "   curl -i http://localhost$ROUTE_PATH"
echo ""
echo "📌 Para probar desde el navegador, usa esta URL:"
echo "   http://localhost$ROUTE_PATH"
echo "========================================"

# Probar la nueva ruta directamente
echo "🔍 Probando la nueva ruta con curl..."
curl -i http://localhost$ROUTE_PATH

echo ""
echo "📝 Si sigue sin funcionar, aquí hay algunas opciones para depurar:"
echo ""
echo "1. Verificar configuración HTTP en APISIX:"
echo "   docker exec -it kit-apisix-1 cat /usr/local/apisix/conf/config.yaml"
echo ""
echo "2. Examinar logs de APISIX:"
echo "   docker logs kit-apisix-1"
echo ""
echo "3. Probar conectividad directa dentro del contenedor APISIX:"
echo "   docker exec -it kit-apisix-1 curl http://$SERVER_IP"
echo ""
echo "4. Crear un hostname para tu servidor en APISIX:"
echo "   docker exec -it kit-apisix-1 sh -c \"echo '$SERVER_IP microserver' >> /etc/hosts\""
echo "   Y luego configurar una ruta usando ese hostname"
echo "========================================"