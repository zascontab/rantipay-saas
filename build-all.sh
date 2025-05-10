#!/bin/bash
set -e

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Iniciando construcción de imágenes locales para Rantipay SaaS${NC}"

# Directorio base
BASE_DIR=$(pwd)

# Construir servicios core de go-saas/kit
echo -e "${YELLOW}Construyendo servicios core...${NC}"
cd $BASE_DIR/kit

# Construir user service
echo -e "${YELLOW}Construyendo user service...${NC}"
cd $BASE_DIR/kit/user
docker build -t go-saas-kit-user:latest .

# Construir saas service
echo -e "${YELLOW}Construyendo saas service...${NC}"
cd $BASE_DIR/kit/saas
docker build -t go-saas-kit-saas:latest .

# Construir sys service
echo -e "${YELLOW}Construyendo sys service...${NC}"
cd $BASE_DIR/kit/sys
docker build -t go-saas-kit-sys:latest .

# Construir realtime service
echo -e "${YELLOW}Construyendo realtime service...${NC}"
cd $BASE_DIR/kit/realtime
docker build -t go-saas-kit-realtime:latest .

# Construir payment service
echo -e "${YELLOW}Construyendo payment service...${NC}"
cd $BASE_DIR/kit/payment
docker build -t go-saas-kit-payment:latest .

# Construir order service
echo -e "${YELLOW}Construyendo order service...${NC}"
cd $BASE_DIR/kit/order
docker build -t go-saas-kit-order:latest .

# Construir product service
echo -e "${YELLOW}Construyendo product service...${NC}"
cd $BASE_DIR/kit/product
docker build -t go-saas-kit-product:latest .

# Construir apisix customizado
echo -e "${YELLOW}Construyendo apisix customizado...${NC}"
cd $BASE_DIR/kit/gateway/apisix
docker build -t go-saas-kit-apisix:latest .

# Construir swagger docs
echo -e "${YELLOW}Construyendo swagger docs...${NC}"
cd $BASE_DIR/kit/openapi
mkdir -p openapi
cp kit-merged.swagger.json openapi/
docker build -t go-saas-kit-swagger:latest .

# Construir frontend
echo -e "${YELLOW}Construyendo frontend...${NC}"
cd $BASE_DIR/kit-frontend
docker build -t go-saas-kit-frontend:latest .

echo -e "${GREEN}Construcción de imágenes completada.${NC}"
echo -e "${GREEN}Ahora puedes ejecutar 'docker-compose -f docker-compose.local.yml up -d' para iniciar el sistema.${NC}"