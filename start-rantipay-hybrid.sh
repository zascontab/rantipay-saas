#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-hybrid-plus.yml"

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS Hybrid   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener cualquier instancia previa
echo -e "${YELLOW}Paso 1: Deteniendo instancias previas...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE down --remove-orphans
echo -e "${GREEN}✓ Instancias previas detenidas${NC}"
echo ""

# Paso 2: Construir las imágenes locales si es necesario
echo -e "${YELLOW}Paso 2: Construyendo imágenes locales...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE build simple-user companies
echo -e "${GREEN}✓ Imágenes construidas${NC}"
echo ""

# Paso 3: Iniciar servicios de infraestructura primero
echo -e "${YELLOW}Paso 3: Iniciando servicios de infraestructura...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d mysqld redis etcd
sleep 10
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 4: Iniciar servicios básicos
echo -e "${YELLOW}Paso 4: Iniciando servicios básicos...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d simple-user companies
sleep 5
echo -e "${GREEN}✓ Servicios básicos iniciados${NC}"
echo ""

# Paso 5: Iniciar API Gateway y Frontend
echo -e "${YELLOW}Paso 5: Iniciando API Gateway y Frontend...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d nginx web
sleep 5
echo -e "${GREEN}✓ API Gateway y Frontend iniciados${NC}"
echo ""

# Paso 6: Verificar todos los servicios
echo -e "${YELLOW}Paso 6: Verificando todos los servicios...${NC}"

# Verificar servicio user
echo -e "${YELLOW}Verificando servicio User:${NC}"
USER_HEALTH=$(curl -s http://localhost:8000/health)
if [[ "$USER_HEALTH" == *"OK"* ]]; then
    echo -e "${GREEN}  ✓ Servicio User está funcionando correctamente${NC}"
    echo -e "${GREEN}    Respuesta: $USER_HEALTH${NC}"
else
    echo -e "${RED}  ✗ Servicio User no está funcionando correctamente${NC}"
    echo -e "${YELLOW}    Respuesta: $USER_HEALTH${NC}"
    echo -e "${YELLOW}  Revisando logs del servicio User:${NC}"
    docker logs --tail 20 rantipay_saas-simple-user-1
fi

# Verificar servicio companies
echo -e "${YELLOW}Verificando servicio Companies:${NC}"
COMPANIES_HEALTH=$(curl -s http://localhost:8010/health)
if [[ "$COMPANIES_HEALTH" == *"OK"* ]]; then
    echo -e "${GREEN}  ✓ Servicio Companies está funcionando correctamente${NC}"
    echo -e "${GREEN}    Respuesta: $COMPANIES_HEALTH${NC}"
else
    echo -e "${RED}  ✗ Servicio Companies no está funcionando correctamente${NC}"
    echo -e "${YELLOW}    Respuesta: $COMPANIES_HEALTH${NC}"
    echo -e "${YELLOW}  Revisando logs del servicio Companies:${NC}"
    docker logs --tail 20 rantipay_saas-companies-1
fi

# Verificar API Gateway
echo -e "${YELLOW}Verificando API Gateway:${NC}"
GATEWAY_HEALTH=$(curl -s http://localhost:81/health)
if [[ "$GATEWAY_HEALTH" == *"Healthy"* ]]; then
    echo -e "${GREEN}  ✓ API Gateway está funcionando correctamente${NC}"
    echo -e "${GREEN}    Respuesta: $GATEWAY_HEALTH${NC}"
else
    echo -e "${RED}  ✗ API Gateway no está funcionando correctamente${NC}"
    echo -e "${YELLOW}    Respuesta: $GATEWAY_HEALTH${NC}"
    echo -e "${YELLOW}  Revisando logs del API Gateway:${NC}"
    docker logs --tail 20 rantipay_saas-nginx-1
fi

# Verificar Frontend
echo -e "${YELLOW}Verificando Frontend:${NC}"
if curl -s -I http://localhost:8080 | grep -q "200 OK"; then
    echo -e "${GREEN}  ✓ Frontend está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ Frontend no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs del Frontend:${NC}"
    docker logs --tail 20 rantipay_saas-web-1
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Plataforma Rantipay SaaS lista para usar   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81${NC}"
echo -e "${GREEN}Servicios disponibles:${NC}"
echo -e "${GREEN}  - User: http://localhost:8000${NC}"
echo -e "${GREEN}  - Companies: http://localhost:8010${NC}"
echo ""
echo -e "${YELLOW}Para iniciar sesión en el servicio de usuario:${NC}"
echo -e "${YELLOW}  - Usuario: admin@rantipay.com${NC}"
echo -e "${YELLOW}  - Contraseña: Admin123!${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f $DOCKER_COMPOSE_FILE down${NC}"
echo ""
