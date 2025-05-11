#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Corrigiendo el Dockerfile...${NC}"

# Crear el Dockerfile corregido
cat > kit/user/Dockerfile.local << 'INNEREOF'
FROM golang:1.20 AS builder

WORKDIR /app
COPY . .

# Compilar el servicio user
WORKDIR /app/user
RUN go mod download
RUN make build

FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
        && rm -rf /var/lib/apt/lists/ \
        && apt-get autoremove -y && apt-get autoclean -y

WORKDIR /app

# Copiar el binario compilado y archivos necesarios
COPY --from=builder /app/user/bin/user /app/
COPY --from=builder /app/user/i18n /app/i18n

EXPOSE 8000
EXPOSE 9000

VOLUME /data/conf
CMD ["./user", "-conf", "/data/conf"]
INNEREOF

echo -e "${GREEN}✓ Dockerfile corregido${NC}"
echo ""

echo -e "${YELLOW}Compilando la imagen Docker...${NC}"
cd kit
docker build -t go-saas-kit-user:latest -f user/Dockerfile.local .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Imagen Docker compilada exitosamente${NC}"
    echo -e "${YELLOW}Ahora puedes iniciar el sistema con:${NC}"
    echo -e "${YELLOW}./start-full-user.sh${NC}"
else
    echo -e "${RED}× Error al compilar la imagen Docker${NC}"
    echo -e "${YELLOW}Revisa los mensajes de error para más información${NC}"
fi
