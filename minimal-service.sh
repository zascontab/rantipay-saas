#!/bin/bash

# Este enfoque alternativo utilizará una versión mínima del servicio
# para desarrollo con hot reload sin depender de la configuración original

echo "🚀 Iniciando servicio mínimo para desarrollo con Hot Reload..."

PROJECT_ROOT=~/developer/projects/rantipay/wankarlab/rantipay-saas/kit
SERVICE_TO_DEVELOP="user" # Cambia esto a "saas" o "sys" según lo que necesites

# Detener servicios existentes
docker stop kit-$SERVICE_TO_DEVELOP-1 || true
pkill -f "CompileDaemon.*$SERVICE_TO_DEVELOP" || true

# Crear directorios necesarios
mkdir -p $PROJECT_ROOT/$SERVICE_TO_DEVELOP/minimal
mkdir -p $PROJECT_ROOT/$SERVICE_TO_DEVELOP/tmp
mkdir -p $PROJECT_ROOT/logs

# Crear un servicio mínimo para desarrollo
cat > $PROJECT_ROOT/$SERVICE_TO_DEVELOP/minimal/main.go << 'EOF'
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	port := "8000" // Puerto por defecto
	if len(os.Args) > 1 && os.Args[1] != "" {
		port = os.Args[1]
	}

	// Manejador básico para todas las rutas
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		fmt.Printf("Recibida petición: %s %s\n", r.Method, r.URL.Path)
		
		// Responder con información básica
		w.Header().Set("Content-Type", "application/json")
		fmt.Fprintf(w, `{
			"service": "%s",
			"status": "running",
			"message": "Versión mínima para desarrollo con Hot Reload",
			"path": "%s",
			"method": "%s"
		}`, os.Getenv("SERVICE_NAME"), r.URL.Path, r.Method)
	})

	// Iniciar servidor
	fmt.Printf("🚀 Iniciando servicio mínimo para %s en puerto %s...\n", 
		os.Getenv("SERVICE_NAME"), port)
	
	// Manejar señales para apagado graceful
	stop := make(chan os.Signal, 1)
	signal.Notify(stop, os.Interrupt, syscall.SIGTERM)
	
	// Iniciar servidor en goroutine
	go func() {
		if err := http.ListenAndServe(":"+port, nil); err != nil {
			log.Fatalf("❌ Error al iniciar servidor: %v", err)
		}
	}()
	
	fmt.Println("✅ Servidor iniciado. Presiona Ctrl+C para detener.")
	
	// Esperar señal para detener
	<-stop
	fmt.Println("🛑 Deteniendo servidor...")
}
EOF

# Crear script de inicio
cat > $PROJECT_ROOT/$SERVICE_TO_DEVELOP/minimal/start.sh << EOF
#!/bin/bash
export SERVICE_NAME="$SERVICE_TO_DEVELOP"
cd $PROJECT_ROOT/$SERVICE_TO_DEVELOP/minimal
go run main.go \$1
EOF
chmod +x $PROJECT_ROOT/$SERVICE_TO_DEVELOP/minimal/start.sh

# Iniciar con CompileDaemon
cd $PROJECT_ROOT/$SERVICE_TO_DEVELOP
echo "🔄 Iniciando servicio mínimo para $SERVICE_TO_DEVELOP con Hot Reload..."

PORT=""
case $SERVICE_TO_DEVELOP in
    user) PORT="8000" ;;
    saas) PORT="8001" ;;
    sys)  PORT="8002" ;;
esac

# Ejecutar CompileDaemon
nohup CompileDaemon \
    --build="go build -o ./tmp/minimal-service ./minimal/main.go" \
    --command="./tmp/minimal-service $PORT" \
    --directory="./minimal" \
    --pattern="(.+\.go)$" \
    --color=true \
    --graceful-kill=true \
    > $PROJECT_ROOT/logs/$SERVICE_TO_DEVELOP-minimal.log 2>&1 &

SERVICE_PID=$!
echo $SERVICE_PID > $PROJECT_ROOT/logs/$SERVICE_TO_DEVELOP-minimal.pid

echo "✅ Servicio mínimo para $SERVICE_TO_DEVELOP iniciado en puerto $PORT (PID: $SERVICE_PID)"

# Configurar APISIX
echo "🔄 Configurando APISIX para redireccionar a servicio mínimo..."
INTERNAL_IP=$(hostname -I | awk '{print $1}')

curl -s http://localhost:9280/apisix/admin/routes/$SERVICE_TO_DEVELOP-minimal -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"/$SERVICE_TO_DEVELOP/*\",
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"$INTERNAL_IP:$PORT\": 1
    }
  }
}"

echo ""
echo "🌟 Servicio mínimo para $SERVICE_TO_DEVELOP iniciado y configurado"
echo "================================================================="
echo "🔍 Puedes probar el servicio en:"
echo "   - Directo: http://localhost:$PORT"
echo "   - A través de APISIX: http://localhost/$SERVICE_TO_DEVELOP"
echo ""
echo "📝 Para ver los logs:"
echo "   tail -f $PROJECT_ROOT/logs/$SERVICE_TO_DEVELOP-minimal.log"
echo ""
echo "🛑 Para detener el servicio:"
echo "   kill \$(cat $PROJECT_ROOT/logs/$SERVICE_TO_DEVELOP-minimal.pid)"
echo "================================================================="