#!/bin/bash

# Este script usa un enfoque más directo con un micro-servidor en Go
# dentro de la red de Docker para resolver los problemas de conectividad

echo "🚀 Configurando solución con servidor Go en Docker..."

PROJECT_ROOT=~/developer/projects/rantipay/wankarlab/rantipay-saas/kit
LOCAL_PORT=8888

# Verificar que el servidor local siga funcionando
if ! curl -s http://localhost:$LOCAL_PORT > /dev/null; then
    echo "❌ Error: El servidor local no está respondiendo en http://localhost:$LOCAL_PORT"
    exit 1
fi
echo "✅ Servidor local verificado en puerto $LOCAL_PORT"

# Crear un microservidor Go 
echo "🔧 Creando microservidor Go..."
mkdir -p $PROJECT_ROOT/docker-server
cat > $PROJECT_ROOT/docker-server/server.go << 'EOF'
package main

import (
    "encoding/json"
    "fmt"
    "log"
    "net/http"
    "os"
    "time"
)

type Response struct {
    Service   string    `json:"service"`
    Status    string    `json:"status"`
    Path      string    `json:"path"`
    Method    string    `json:"method"`
    Timestamp time.Time `json:"timestamp"`
}

func main() {
    port := "80"
    if len(os.Args) > 1 {
        port = os.Args[1]
    }
    
    serviceName := "user-docker"
    if os.Getenv("SERVICE_NAME") != "" {
        serviceName = os.Getenv("SERVICE_NAME")
    }
    
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        log.Printf("Recibida petición: %s %s", r.Method, r.URL.Path)
        
        // Crear respuesta
        resp := Response{
            Service:   serviceName,
            Status:    "running",
            Path:      r.URL.Path,
            Method:    r.Method,
            Timestamp: time.Now(),
        }
        
        // Enviar respuesta JSON
        w.Header().Set("Content-Type", "application/json")
        json.NewEncoder(w).Encode(resp)
    })
    
    fmt.Printf("Iniciando servidor en puerto %s...\n", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}
EOF

# Crear Dockerfile
cat > $PROJECT_ROOT/docker-server/Dockerfile << 'EOF'
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY server.go .
RUN go build -o server server.go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/server /app/
ENV SERVICE_NAME="user-docker"
EXPOSE 80
CMD ["/app/server"]
EOF

# Construir y ejecutar la imagen Docker
echo "🔨 Construyendo imagen Docker..."
cd $PROJECT_ROOT/docker-server
docker build -t user-microserver .

# Detener contenedores existentes
docker rm -f user-microserver 2>/dev/null || true

# Iniciar el contenedor
echo "🚀 Iniciando contenedor con microservidor..."
docker run -d --name user-microserver \
    --network kit_default \
    -e SERVICE_NAME="user-docker" \
    user-microserver

# Esperar a que el servidor esté listo
echo "⏳ Esperando a que el servidor inicie..."
sleep 3

# Obtener la IP del contenedor
USER_SERVER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' user-microserver)
echo "🔍 IP del microservidor: $USER_SERVER_IP"

# Configurar APISIX para usar el nuevo microservidor
echo "🔄 Configurando APISIX para usar el microservidor..."
curl -s http://localhost:9280/apisix/admin/routes/user-micro -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"/user-go/*\",
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"$USER_SERVER_IP:80\": 1
    }
  }
}"

echo ""
echo "🌟 Servidor Go en Docker configurado"
echo "======================================"
echo "📌 Hemos creado un servidor Go dentro de la red Docker para"
echo "   garantizar la conectividad con APISIX."
echo ""
echo "📌 Prueba accediendo a:"
echo "   http://localhost/user-go"
echo ""
echo "📝 Para ver los logs del servidor:"
echo "   docker logs user-microserver"
echo ""
echo "🛑 Para detener el servidor:"
echo "   docker stop user-microserver"
echo "======================================"

# Verificar que el servidor responde
echo "🔍 Verificando conectividad con el servidor..."
docker exec kit-apisix-1 curl -s http://$USER_SERVER_IP

# Finalmente, ofrecer instrucciones para desarrollo
echo ""
echo "📚 Para desarrollo, ahora puedes:"
echo "1. Continuar usando tu servidor local en el puerto $LOCAL_PORT para pruebas directas"
echo "2. Actualizar el código en docker-server/server.go y reconstruir cuando necesites cambios:"
echo "   cd $PROJECT_ROOT/docker-server"
echo "   docker build -t user-microserver ."
echo "   docker restart user-microserver"
echo ""
echo "🔗 El patrón para las URLs de APISIX es:"
echo "   - http://localhost/user-go/* → Servidor Go en Docker"
echo "======================================"