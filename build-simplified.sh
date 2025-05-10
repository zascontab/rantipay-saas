#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Iniciando construcción simplificada de imágenes locales${NC}"

# Directorio base
BASE_DIR=$(pwd)
KIT_DIR="$BASE_DIR/kit"

build_service() {
    local service=$1
    echo -e "${YELLOW}Construyendo $service service...${NC}"
    
    # Crear Dockerfile temporal
    cat > $KIT_DIR/$service/Dockerfile.simplified << EOF
FROM golang:1.20 as builder

WORKDIR /app
COPY . .

# Compilar el binario
RUN ls -la && \
    ls -la $service && \
    ls -la $service/cmd && \
    cd $service && go build -o $service ./cmd/user

# Etapa final
FROM debian:stable-slim

RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /app/$service/$service /app/$service

# Verificar si existen los directorios antes de copiarlos
RUN mkdir -p /app/configs /app/i18n

# No copiamos configs ni i18n por ahora, los montaremos como volúmenes

EXPOSE 8000 9000
ENTRYPOINT ["/app/$service", "-conf", "/data/conf/$service.yaml"]
EOF

    # Construir la imagen
    cd $KIT_DIR
    docker build -t go-saas-kit-$service:local -f $service/Dockerfile.simplified .
    cd $BASE_DIR
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}$service construido correctamente${NC}"
    else
        echo -e "${RED}Error al construir $service${NC}"
        exit 1
    fi
}

# Construir un servicio a la vez para ahorrar espacio en disco
build_service "user"

echo -e "${GREEN}Construcción completa. Actualiza docker-compose-local.yml para usar imágenes locales.${NC}"
