#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Compilando servicios de go-saas/kit   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Navegar al directorio kit
cd ~/developer/projects/rantipay/wankarlab/rantipay_saas/kit

# Crear directorio bin si no existe
mkdir -p bin

# Compilar servicio User
echo -e "${YELLOW}Compilando servicio User...${NC}"
make -f user/Makefile build
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al compilar servicio User${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicio User compilado correctamente${NC}"
echo ""

# Compilar servicio SaaS
echo -e "${YELLOW}Compilando servicio SaaS...${NC}"
make -f saas/Makefile build
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al compilar servicio SaaS${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicio SaaS compilado correctamente${NC}"
echo ""

# Compilar servicio Sys
echo -e "${YELLOW}Compilando servicio Sys...${NC}"
make -f sys/Makefile build
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al compilar servicio Sys${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicio Sys compilado correctamente${NC}"
echo ""

# Verificar que los binarios existen
echo -e "${YELLOW}Verificando binarios...${NC}"
ls -la bin/
echo ""

# Volver al directorio raíz
cd ~/developer/projects/rantipay/wankarlab/rantipay_saas

# Crear directorio para Dockerfiles si no existe
mkdir -p dockerfiles

# Crear Dockerfile para User
echo -e "${YELLOW}Creando Dockerfile para User...${NC}"
cat > dockerfiles/Dockerfile.user << 'EOFINNER'
FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
        && rm -rf /var/lib/apt/lists/ \
        && apt-get autoremove -y && apt-get autoclean -y

WORKDIR /app

COPY kit/bin/user /app/
COPY configs /data/conf

EXPOSE 8000
EXPOSE 9000
VOLUME /data/conf

CMD ["./user", "-conf", "/data/conf"]
EOFINNER
echo -e "${GREEN}✓ Dockerfile para User creado${NC}"
echo ""

# Crear Dockerfile para SaaS
echo -e "${YELLOW}Creando Dockerfile para SaaS...${NC}"
cat > dockerfiles/Dockerfile.saas << 'EOFINNER'
FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
        && rm -rf /var/lib/apt/lists/ \
        && apt-get autoremove -y && apt-get autoclean -y

WORKDIR /app

COPY kit/bin/saas /app/
COPY configs /data/conf

EXPOSE 8000
EXPOSE 9000
VOLUME /data/conf

CMD ["./saas", "-conf", "/data/conf"]
EOFINNER
echo -e "${GREEN}✓ Dockerfile para SaaS creado${NC}"
echo ""

# Crear Dockerfile para Sys
echo -e "${YELLOW}Creando Dockerfile para Sys...${NC}"
cat > dockerfiles/Dockerfile.sys << 'EOFINNER'
FROM debian:stable-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
        && rm -rf /var/lib/apt/lists/ \
        && apt-get autoremove -y && apt-get autoclean -y

WORKDIR /app

COPY kit/bin/sys /app/
COPY configs /data/conf

EXPOSE 8000
EXPOSE 9000
VOLUME /data/conf

CMD ["./sys", "-conf", "/data/conf"]
EOFINNER
echo -e "${GREEN}✓ Dockerfile para Sys creado${NC}"
echo ""

# Construir imágenes Docker
echo -e "${YELLOW}Construyendo imágenes Docker...${NC}"
echo -e "${YELLOW}1. Imagen para User...${NC}"
docker build -t go-saas-kit-user:latest -f dockerfiles/Dockerfile.user .
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al construir imagen para User${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Imagen para User construida correctamente${NC}"
echo ""

echo -e "${YELLOW}2. Imagen para SaaS...${NC}"
docker build -t go-saas-kit-saas:latest -f dockerfiles/Dockerfile.saas .
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al construir imagen para SaaS${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Imagen para SaaS construida correctamente${NC}"
echo ""

echo -e "${YELLOW}3. Imagen para Sys...${NC}"
docker build -t go-saas-kit-sys:latest -f dockerfiles/Dockerfile.sys .
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al construir imagen para Sys${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Imagen para Sys construida correctamente${NC}"
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Servicios compilados y empaquetados   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Imágenes Docker disponibles:${NC}"
docker images | grep go-saas-kit-
echo ""
echo -e "${YELLOW}Para actualizar el docker-compose con estas imágenes, ejecuta:${NC}"
echo -e "${YELLOW}./update-compose.sh${NC}"
