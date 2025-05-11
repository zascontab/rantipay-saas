#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-hybrid-plus.yml"

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Corrigiendo login web en Rantipay SaaS   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener los servicios
echo -e "${YELLOW}Paso 1: Deteniendo servicios actuales...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE down
echo -e "${GREEN}✓ Servicios detenidos${NC}"
echo ""

# Paso 2: Reconstruir el servicio de usuario simplificado
echo -e "${YELLOW}Paso 2: Reconstruyendo el servicio de usuario simplificado...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE build simple-user
echo -e "${GREEN}✓ Servicio de usuario reconstruido${NC}"
echo ""

# Paso 3: Iniciar los servicios
echo -e "${YELLOW}Paso 3: Iniciando servicios...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d
echo -e "${GREEN}✓ Servicios iniciados${NC}"
echo ""

# Paso 4: Esperar a que los servicios estén disponibles
echo -e "${YELLOW}Paso 4: Esperando a que los servicios estén disponibles...${NC}"
sleep 5
echo -e "${GREEN}✓ Espera completada${NC}"
echo ""

# Paso 5: Verificar los nuevos endpoints
echo -e "${YELLOW}Paso 5: Verificando los nuevos endpoints...${NC}"

echo -e "${YELLOW}5.1: Verificando /v1/account/profile...${NC}"
curl -s http://localhost:81/v1/account/profile | head -50
echo -e "\n${GREEN}✓ Endpoint verificado${NC}"
echo ""

echo -e "${YELLOW}5.2: Verificando /v1/auth/web/login...${NC}"
curl -s "http://localhost:81/v1/auth/web/login?redirect=%2Fdashboard%2Fworkbench" | head -50
echo -e "\n${GREEN}✓ Endpoint verificado${NC}"
echo ""

echo -e "${YELLOW}5.3: Verificando /v1/auth/web/logout...${NC}"
curl -s -X POST http://localhost:81/v1/auth/web/logout | head -50
echo -e "\n${GREEN}✓ Endpoint verificado${NC}"
echo ""

echo -e "${YELLOW}5.4: Verificando /v1/sys/locale/msgs...${NC}"
curl -s http://localhost:81/v1/sys/locale/msgs | head -50
echo -e "\n${GREEN}✓ Endpoint verificado${NC}"
echo ""

echo -e "${YELLOW}5.5: Verificando /v1/saas/plans/available...${NC}"
curl -s http://localhost:81/v1/saas/plans/available | head -50
echo -e "\n${GREEN}✓ Endpoint verificado${NC}"
echo ""

echo -e "${YELLOW}5.6: Verificando /v1/realtime/notification/list...${NC}"
curl -s -X POST http://localhost:81/v1/realtime/notification/list | head -50
echo -e "\n${GREEN}✓ Endpoint verificado${NC}"
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Corrección completada   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Ahora el login web debería funcionar correctamente.${NC}"
echo -e "${YELLOW}1. Abre http://localhost:8080 en tu navegador${NC}"
echo -e "${YELLOW}2. Inicia sesión con cualquier nombre de usuario y contraseña${NC}"
echo -e "${YELLOW}3. Deberías ser redirigido al panel de control${NC}"
echo ""
echo -e "${YELLOW}Si continúas teniendo problemas, verifica los logs:${NC}"
echo -e "${YELLOW}docker logs rantipay_saas-simple-user-1${NC}"
echo -e "${YELLOW}docker logs rantipay_saas-nginx-1${NC}"
echo -e "${YELLOW}docker logs rantipay_saas-web-1${NC}"
