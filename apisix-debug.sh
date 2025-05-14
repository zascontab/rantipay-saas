#!/bin/bash

# Script para investigar y resolver los problemas de enrutamiento en APISIX
# Nombre del archivo: apisix-debug.sh

echo "🔍 Iniciando investigación profunda del problema con APISIX..."

# Verificar que el microservidor siga funcionando
SERVER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' user-microserver)
if [ -z "$SERVER_IP" ]; then
    echo "❌ Error: No se encontró el contenedor user-microserver"
    echo "   Por favor, ejecuta primero el script docker-go-server.sh"
    exit 1
fi

echo "✅ Microservidor encontrado en IP: $SERVER_IP"

# Investigar si APISIX tiene alguna configuración global que pueda estar afectando
echo "🔍 Examinando configuración de APISIX..."
docker exec -it kit-apisix-1 cat /usr/local/apisix/conf/config.yaml > /tmp/apisix-config.yaml
echo "✅ Configuración guardada en /tmp/apisix-config.yaml"

# Verificar todas las rutas configuradas
echo "🔍 Obteniendo detalles de todas las rutas configuradas..."
curl -s http://localhost:9280/apisix/admin/routes/web -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" > /tmp/route-web.json
echo "✅ Detalles de la ruta 'web' guardados en /tmp/route-web.json"

# Investigar el plugin global del dashboard
echo "🔍 Investigando si hay plugins globales configurados..."
curl -s http://localhost:9280/apisix/admin/global_rules -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" > /tmp/global-rules.json
echo "✅ Reglas globales guardadas en /tmp/global-rules.json"

# Investigar si hay un frontend sirviendo estas páginas
echo "🔍 Verificando qué contenedor está sirviendo el frontend..."
docker ps --format "{{.Names}}" | grep -i web

# Investigar cómo está configurada la ruta principal web
echo "🔍 Analizando la ruta principal que puede estar capturando todas las solicitudes..."
ROUTE_WEB=$(cat /tmp/route-web.json)
echo "Ruta web: $ROUTE_WEB"

# Validar que se puede acceder al servidor Go directamente desde APISIX
echo "🔍 Verificando acceso directo al servidor Go desde APISIX..."
docker exec -it kit-apisix-1 curl -v http://$SERVER_IP | tee /tmp/direct-response.txt

# Crear una nueva prueba con un puerto local diferente
echo "🔄 Creando un servidor de prueba en puerto 9999..."
cat > /tmp/test-server.go << 'EOF'
package main

import (
    "fmt"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Println("Recibida petición:", r.Method, r.URL.Path)
        w.Header().Set("Content-Type", "application/json")
        fmt.Fprintf(w, `{"test":"success","path":"%s"}`, r.URL.Path)
    })
    
    fmt.Println("Servidor de prueba iniciando en puerto 9999...")
    if err := http.ListenAndServe(":9999", nil); err != nil {
        fmt.Println("Error:", err)
    }
}
EOF

# Crear un proxy de prueba muy específico
echo "🔄 Creando proxy de prueba con un servlet muy específico..."

# Eliminar rutas anteriores para evitar conflictos
curl -s -X DELETE http://localhost:9280/apisix/admin/routes/test-route -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1"

# Crear identificador único para esta prueba
TEST_PATH="/test_$(date +%s)"
echo "📌 Ruta de prueba: $TEST_PATH"

# Crear una ruta muy específica con la prioridad más alta posible
curl -s http://localhost:9280/apisix/admin/routes/test-route -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"$TEST_PATH/*\",
  \"priority\": 10000,
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"$SERVER_IP:80\": 1
    }
  }
}" | tee /tmp/test-route-response.json

echo "✅ Ruta de prueba creada"

# Probar la ruta directamente
echo "🔍 Probando la ruta de prueba..."
curl -v http://localhost$TEST_PATH | tee /tmp/test-route-result.txt

# Recopilar información para análisis
echo ""
echo "📊 Resumen de la investigación"
echo "======================================"
echo "1. Microservidor Go en IP: $SERVER_IP"
echo "2. Ruta de prueba creada: $TEST_PATH"
echo "3. Resultado de la prueba guardado en: /tmp/test-route-result.txt"
echo ""
echo "📌 Prueba esta URL específica:"
echo "   curl -v http://localhost$TEST_PATH"
echo ""
echo "⚠️ Si sigue sin funcionar, el problema podría estar en una configuración"
echo "   global o en algún plugin que esté interceptando todas las solicitudes."
echo ""
echo "🔄 Intenta reiniciar APISIX para aplicar los cambios:"
echo "   docker restart kit-apisix-1"
echo "======================================"

# Sugerencias para una solución definitiva
echo ""
echo "💡 Sugerencia para desarrollo:"
echo "Si continúas teniendo problemas con APISIX, la opción más simple"
echo "sería desarrollar directamente contra tu servidor local en el puerto 8888,"
echo "obviando completamente APISIX durante el desarrollo."
echo ""
echo "Para ello, simplemente enfoca tu desarrollo en:"
echo "1. Modificar ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/minimal/server.go"
echo "2. Usar directamente http://localhost:8888 para pruebas"
echo "3. Cuando esté listo, integrar tus cambios en el servicio principal"
echo ""