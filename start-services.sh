#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando servicios core de go-saas/kit   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Verificar si los servicios están compilados
if [ ! -f "kit/user/bin/user" ] || [ ! -f "kit/saas/bin/saas" ] || [ ! -f "kit/sys/bin/sys" ]; then
    echo -e "${RED}× Error: Los servicios no están compilados correctamente${NC}"
    echo -e "${YELLOW}Por favor, ejecuta primero el script de compilación${NC}"
    exit 1
fi

# Iniciar servicio User
echo -e "${YELLOW}Iniciando servicio User...${NC}"
cd kit/user
./bin/user -conf ../../configs/user > ../../logs/user.log 2>&1 &
USER_PID=$!
echo $USER_PID > ../../.user.pid
cd ../..
echo -e "${GREEN}✓ Servicio User iniciado con PID $USER_PID${NC}"

# Esperar a que User esté listo
echo -e "${YELLOW}Esperando a que User esté listo...${NC}"
sleep 5

# Iniciar servicio SaaS
echo -e "${YELLOW}Iniciando servicio SaaS...${NC}"
cd kit/saas
./bin/saas -conf ../../configs/saas > ../../logs/saas.log 2>&1 &
SAAS_PID=$!
echo $SAAS_PID > ../../.saas.pid
cd ../..
echo -e "${GREEN}✓ Servicio SaaS iniciado con PID $SAAS_PID${NC}"

# Esperar a que SaaS esté listo
echo -e "${YELLOW}Esperando a que SaaS esté listo...${NC}"
sleep 5

# Iniciar servicio Sys
echo -e "${YELLOW}Iniciando servicio Sys...${NC}"
cd kit/sys
./bin/sys -conf ../../configs/sys > ../../logs/sys.log 2>&1 &
SYS_PID=$!
echo $SYS_PID > ../../.sys.pid
cd ../..
echo -e "${GREEN}✓ Servicio Sys iniciado con PID $SYS_PID${NC}"

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Servicios core iniciados correctamente   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${YELLOW}Servicios disponibles:${NC}"
echo -e "${GREEN}- User: http://localhost:8000${NC}"
echo -e "${GREEN}- SaaS: http://localhost:8001${NC}"
echo -e "${GREEN}- Sys: http://localhost:8002${NC}"
echo ""
echo -e "${YELLOW}Para detener los servicios, ejecuta:${NC}"
echo -e "${GREEN}./stop-services.sh${NC}"