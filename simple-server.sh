#!/bin/bash

# Script simplificado de servicio mínimo para desarrollo Hot Reload
# Con correcciones para los problemas identificados

echo "🚀 Iniciando servicio HTTP mínimo con Hot Reload..."

# Directorio del proyecto y servicio
PROJECT_ROOT=~/developer/projects/rantipay/wankarlab/rantipay-saas/kit
SERVICE="user"  # Cambia a saas o sys según necesites
PORT=8000       # Puerto para el servicio (8000 para user, 8001 para saas, 8002 para sys)

# Crear directorios necesarios
mkdir -p $PROJECT_ROOT/minimal
mkdir -p $PROJECT_ROOT/logs

# Limpiar cualquier proceso anterior
echo "🧹 Limpiando procesos anteriores..."
pkill -f "minimal-server" || true
docker stop kit-$SERVICE-1 || true

# Crear un servidor HTTP mínimo directamente en el directorio raíz
cat > $PROJECT_ROOT/minimal/server.go << 'EOF'
package main

import (
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	// Configuración básica
	var port string
	flag.StringVar(&port, "port", "8000", "Puerto para el servidor HTTP")
	flag.Parse()

	// Identificar qué servicio estamos simulando
	serviceName := os.Getenv("SERVICE_NAME")
	if serviceName == "" {
		serviceName = "user-minimal"
	}

	fmt.Printf("🚀 Iniciando servidor mínimo para %s en puerto %s\n", serviceName, port)

	// Manejador para la ruta raíz
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Recibida petición: %s %s", r.Method, r.URL.Path)
		
		// Responder con información básica
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{
			"service": "%s",
			"status": "running",
			"path": "%s",
			"method": "%s",
			"timestamp": "%s"
		}`, serviceName, r.URL.Path, r.Method, time.Now().Format(time.RFC3339))
	})

	// Iniciar el servidor
	serverAddr := ":" + port
	fmt.Printf("Servidor escuchando en http://localhost:%s\n", port)
	if err := http.ListenAndServe(serverAddr, nil); err != nil {
		log.Fatalf("❌ Error al iniciar servidor: %v", err)
	}
}
EOF

# Compilar el servidor
echo "🔨 Compilando servidor mínimo..."
cd $PROJECT_ROOT/minimal
go build -o minimal-server server.go

if [ ! -f ./minimal-server ]; then
    echo "❌ Error al compilar el servidor mínimo."
    exit 1
fi

# Iniciar el servidor
echo "🚀 Iniciando servidor mínimo..."
export SERVICE_NAME="$SERVICE-minimal"
nohup ./minimal-server --port=$PORT > $PROJECT_ROOT/logs/$SERVICE-minimal.log 2>&1 &
SERVER_PID=$!

echo $SERVER_PID > $PROJECT_ROOT/logs/$SERVICE-minimal.pid

# Verificar que el servidor esté funcionando
echo "⏳ Esperando a que el servidor inicie..."
sleep 2

if ! ps -p $SERVER_PID > /dev/null; then
    echo "❌ El servidor no pudo iniciarse. Verifica los logs:"
    cat $PROJECT_ROOT/logs/$SERVICE-minimal.log
    exit 1
fi

echo "✅ Servidor mínimo iniciado exitosamente (PID: $SERVER_PID)"

# Configurar APISIX para rutear al servidor local
echo "🔄 Configurando APISIX para redireccionar al servidor mínimo..."

# Usar localhost en lugar de IP externa
curl -s http://localhost:9280/apisix/admin/routes/$SERVICE-minimal -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '{
  "uri": "/'$SERVICE'/*",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "host.docker.internal:'$PORT'": 1
    }
  }
}'

echo ""
echo "🌟 Servicio mínimo configurado correctamente"
echo "============================================="
echo "📌 Acceso directo: http://localhost:$PORT"
echo "📌 Acceso vía APISIX: http://localhost/$SERVICE"
echo ""
echo "📝 Para ver los logs en tiempo real:"
echo "   tail -f $PROJECT_ROOT/logs/$SERVICE-minimal.log"
echo ""
echo "🔄 Para detener el servicio:"
echo "   kill $(cat $PROJECT_ROOT/logs/$SERVICE-minimal.pid)"
echo "============================================="

# Probar si el servicio responde localmente
if curl -s http://localhost:$PORT > /dev/null; then
    echo "✅ Confirmado: El servicio responde localmente."
else
    echo "⚠️ Advertencia: El servicio no responde localmente."
fi

# Sugerir crear un tunnel desde docker a localhost como solución alternativa
echo ""
echo "💡 Si APISIX sigue sin poder acceder al servicio, prueba este comando:"
echo "   docker run -d --name socat-tunnel --network=kit_default -p 8000:8000 alpine/socat tcp-listen:8000,fork,reuseaddr tcp-connect:host.docker.internal:8000"
echo "   Este comando crea un túnel desde la red Docker a tu localhost."