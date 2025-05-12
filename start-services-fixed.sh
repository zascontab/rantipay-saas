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

# Matar cualquier proceso existente
echo -e "${YELLOW}Deteniendo servicios existentes...${NC}"
pkill -f "bin/user" || true
pkill -f "bin/saas" || true
pkill -f "bin/sys" || true
sleep 2

# Crear la base de datos si no existe
echo -e "${YELLOW}Verificando la base de datos...${NC}"
docker exec -it mysql mysql -u root -prantipay123 -e "CREATE DATABASE IF NOT EXISTS rantipay;"

# Usar la ruta correcta a los binarios
USER_BIN="./bin/user"
SAAS_BIN="./bin/saas"
SYS_BIN="./bin/sys"

# Crear directorios de logs si no existen
mkdir -p logs

# Iniciar los servicios
echo -e "${YELLOW}Iniciando servicio User...${NC}"
nohup $USER_BIN -conf configs/user > logs/user.log 2>&1 &
USER_PID=$!
echo -e "${GREEN}✓ Servicio User iniciado con PID $USER_PID${NC}"
echo -e "${YELLOW}Esperando a que User esté listo...${NC}"
sleep 10

echo -e "${YELLOW}Iniciando servicio SaaS...${NC}"
nohup $SAAS_BIN -conf configs/saas > logs/saas.log 2>&1 &
SAAS_PID=$!
echo -e "${GREEN}✓ Servicio SaaS iniciado con PID $SAAS_PID${NC}"
echo -e "${YELLOW}Esperando a que SaaS esté listo...${NC}"
sleep 10

echo -e "${YELLOW}Iniciando servicio Sys...${NC}"
nohup $SYS_BIN -conf configs/sys > logs/sys.log 2>&1 &
SYS_PID=$!
echo -e "${GREEN}✓ Servicio Sys iniciado con PID $SYS_PID${NC}"

# Verificar si los servicios se están ejecutando
sleep 5
if ps -p $USER_PID > /dev/null; then
    echo -e "${GREEN}Servicio User está corriendo con PID $USER_PID${NC}"
else
    echo -e "${RED}Servicio User no está corriendo. Revisar logs/user.log${NC}"
fi

if ps -p $SAAS_PID > /dev/null; then
    echo -e "${GREEN}Servicio SaaS está corriendo con PID $SAAS_PID${NC}"
else
    echo -e "${RED}Servicio SaaS no está corriendo. Revisar logs/saas.log${NC}"
fi

if ps -p $SYS_PID > /dev/null; then
    echo -e "${GREEN}Servicio Sys está corriendo con PID $SYS_PID${NC}"
else
    echo -e "${RED}Servicio Sys no está corriendo. Revisar logs/sys.log${NC}"
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Servicios core iniciados   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "Servicios disponibles:"
echo -e "- User: http://localhost:8000"
echo -e "- SaaS: http://localhost:8001"
echo -e "- Sys: http://localhost:8002"
echo -e "- Companies: http://localhost:8010"
echo ""
echo -e "Para detener los servicios, ejecuta:"
echo -e "./stop-services.sh"