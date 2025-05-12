#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Configurando entorno completo Rantipay SaaS   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Crear directorio para logs
mkdir -p logs

# 1. Configurar entorno base
echo -e "${YELLOW}1. Configurando entorno base...${NC}"
./setup-env.sh
echo -e "${GREEN}✓ Entorno base configurado${NC}"
echo ""

# 2. Compilar servicios core
echo -e "${YELLOW}2. Compilando servicios core...${NC}"
./compile-services.sh
echo -e "${GREEN}✓ Servicios core compilados${NC}"
echo ""

# 3. Iniciar servicios core
echo -e "${YELLOW}3. Iniciando servicios core...${NC}"
./start-services.sh
echo -e "${GREEN}✓ Servicios core iniciados${NC}"
echo ""

# 4. Configurar frontend temporal
echo -e "${YELLOW}4. Configurando frontend temporal...${NC}"
./setup-frontend.sh
echo -e "${GREEN}✓ Frontend configurado${NC}"
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Entorno Rantipay SaaS configurado y en ejecución   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${YELLOW}Para acceder a la plataforma:${NC}"
echo -e "${GREEN}Frontend: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway: http://localhost:9080${NC}"
echo -e "${GREEN}Credenciales: admin@rantipay.com / Admin123!${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${GREEN}./stop-services.sh${NC}"
echo -e "${GREEN}docker compose down${NC}"