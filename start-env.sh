#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Iniciando entorno Rantipay SaaS...${NC}"
docker compose up -d

# Esperar a que los servicios estén disponibles
echo -e "${YELLOW}Esperando a que los servicios estén disponibles...${NC}"
sleep 20

echo -e "${GREEN}Entorno iniciado correctamente${NC}"
echo ""
echo -e "${YELLOW}Servicios disponibles:${NC}"
echo -e "${GREEN}Frontend: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway: http://localhost:9080${NC}"
echo -e "${GREEN}APISIX Dashboard: http://localhost:9000${NC}"
echo ""
echo -e "${YELLOW}Credenciales:${NC}"
echo -e "${GREEN}Usuario: admin@rantipay.com${NC}"
echo -e "${GREEN}Contraseña: Admin123!${NC}"
