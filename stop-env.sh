#!/bin/bash
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Deteniendo entorno Rantipay SaaS...${NC}"
docker compose down

echo -e "${GREEN}Entorno detenido correctamente${NC}"
