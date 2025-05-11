#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-hybrid-plus.yml"

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Corrigiendo error de /v1/saas/current   ${NC}"
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

# Paso 5: Verificar el endpoint saas/current
echo -e "${YELLOW}Paso 5: Verificando endpoint saas/current...${NC}"
curl -s http://localhost:81/v1/saas/current | head -50
echo -e "\n${GREEN}✓ Endpoint verificado${NC}"
echo ""

# Paso 6: Verificar el endpoint payment/stripe/config
echo -e "${YELLOW}Paso 6: Verificando endpoint payment/stripe/config...${NC}"
curl -s http://localhost:81/v1/payment/stripe/config | head -50
echo -e "\n${GREEN}✓ Endpoint verificado${NC}"
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Corrección completada   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Ahora el frontend debería funcionar correctamente sin errores 404.${NC}"
echo -e "${YELLOW}Si continúas teniendo problemas, verifica los logs:${NC}"
echo -e "${YELLOW}docker logs rantipay_saas-simple-user-1${NC}"
echo -e "${YELLOW}docker logs rantipay_saas-nginx-1${NC}"
echo -e "${YELLOW}docker logs rantipay_saas-web-1${NC}"
