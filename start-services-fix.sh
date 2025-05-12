#!/bin/bash

# Colors for messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando servicios core de go-saas/kit (ajustado)   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Verificar si los binarios existen
if [ ! -f "bin/user" ]; then
    echo -e "${RED}Error: No se encuentra bin/user${NC}"
    ls -la bin/
    exit 1
fi

# Crear directorio para logs
mkdir -p logs

# Iniciar servicio User
echo -e "${YELLOW}Iniciando servicio User...${NC}"
./bin/user -conf configs/user > logs/user.log 2>&1 &
USER_PID=$!
echo $USER_PID > .user.pid
echo -e "${GREEN}✓ Servicio User iniciado con PID $USER_PID${NC}"

# Esperar a que User esté listo
echo -e "${YELLOW}Esperando a que User esté listo...${NC}"
sleep 5

# Iniciar servicio SaaS
echo -e "${YELLOW}Iniciando servicio SaaS...${NC}"
./bin/saas -conf configs/saas > logs/saas.log 2>&1 &
SAAS_PID=$!
echo $SAAS_PID > .saas.pid
echo -e "${GREEN}✓ Servicio SaaS iniciado con PID $SAAS_PID${NC}"

# Esperar a que SaaS esté listo
echo -e "${YELLOW}Esperando a que SaaS esté listo...${NC}"
sleep 5

# Iniciar servicio Sys
echo -e "${YELLOW}Iniciando servicio Sys...${NC}"
./bin/sys -conf configs/sys > logs/sys.log 2>&1 &
SYS_PID=$!
echo $SYS_PID > .sys.pid
echo -e "${GREEN}✓ Servicio Sys iniciado con PID $SYS_PID${NC}"

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Servicios core iniciados (ajustado)   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${YELLOW}Servicios disponibles:${NC}"
echo -e "${GREEN}- User: http://localhost:8000${NC}"
echo -e "${GREEN}- SaaS: http://localhost:8001${NC}"
echo -e "${GREEN}- Sys: http://localhost:8002${NC}"
echo -e "${GREEN}- Companies: http://localhost:8010${NC}"
echo ""
echo -e "${YELLOW}Para detener los servicios, ejecuta:${NC}"
echo -e "${GREEN}./stop-services.sh${NC}"
