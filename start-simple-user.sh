#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando entorno con simple-user   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener los servicios actuales
echo -e "${YELLOW}Paso 1: Deteniendo los servicios actuales...${NC}"
docker compose -f docker-compose-simple-user.yml down
echo -e "${GREEN}✓ Servicios detenidos${NC}"
echo ""

# Paso 2: Construir el servicio simple-user
echo -e "${YELLOW}Paso 2: Construyendo el servicio simple-user...${NC}"
docker compose -f docker-compose-simple-user.yml build
echo -e "${GREEN}✓ Servicio construido${NC}"
echo ""

# Paso 3: Iniciar los servicios
echo -e "${YELLOW}Paso 3: Iniciando los servicios...${NC}"
docker compose -f docker-compose-simple-user.yml up -d
echo -e "${GREEN}✓ Servicios iniciados${NC}"
echo ""

# Paso 4: Verificar el estado de los servicios
echo -e "${YELLOW}Paso 4: Verificando el estado de los servicios...${NC}"
docker ps | grep -E "simple-user|nginx|web|mysql|redis|etcd"
echo ""

# Paso 5: Verificar el servicio simple-user
echo -e "${YELLOW}Paso 5: Verificando el servicio simple-user...${NC}"
sleep 5
curl -s http://localhost:8000/health
echo -e "\n"

# Paso 6: Verificar el API Gateway
echo -e "${YELLOW}Paso 6: Verificando el API Gateway...${NC}"
curl -s http://localhost:81/health
echo -e "\n"

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Entorno iniciado correctamente   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Servicios disponibles:${NC}"
echo -e "- Frontend: http://localhost:8080"
echo -e "- API Gateway: http://localhost:81"
echo -e "- Servicio simple-user: http://localhost:8000"
echo ""
echo -e "${YELLOW}Credenciales de inicio de sesión:${NC}"
echo -e "- Usuario: ${GREEN}admin@rantipay.com${NC}"
echo -e "- Contraseña: ${GREEN}Admin123!${NC}"
echo ""
echo -e "${YELLOW}Para detener los servicios:${NC}"
echo -e "${YELLOW}docker compose -f docker-compose-simple-user.yml down${NC}"
