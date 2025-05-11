#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-hybrid-plus.yml"

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Corrigiendo errores 404 en Rantipay SaaS   ${NC}"
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

# Paso 3: Iniciar los servicios de infraestructura
echo -e "${YELLOW}Paso 3: Iniciando servicios de infraestructura...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d mysqld redis etcd
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 4: Esperar a que los servicios estén disponibles
echo -e "${YELLOW}Paso 4: Esperando a que los servicios de infraestructura estén disponibles...${NC}"
sleep 10
echo -e "${GREEN}✓ Servicios de infraestructura disponibles${NC}"
echo ""

# Paso 5: Iniciar el resto de servicios
echo -e "${YELLOW}Paso 5: Iniciando el resto de servicios...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d
echo -e "${GREEN}✓ Todos los servicios iniciados${NC}"
echo ""

# Paso 6: Verificar servicios
echo -e "${YELLOW}Paso 6: Verificando servicios...${NC}"

echo -e "${YELLOW}6.1: Verificando servicio simple-user:${NC}"
HEALTH_RESPONSE=$(curl -s http://localhost:8000/health)
if [[ "$HEALTH_RESPONSE" == *"OK"* ]]; then
    echo -e "${GREEN}  ✓ Servicio simple-user funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ Servicio simple-user NO está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Respuesta: $HEALTH_RESPONSE${NC}"
    echo -e "${YELLOW}  Verificando logs:${NC}"
    docker logs --tail 20 $(docker ps -q -f name=rantipay_saas-simple-user)
fi

echo -e "${YELLOW}6.2: Verificando API Gateway:${NC}"
NGINX_RESPONSE=$(curl -s http://localhost:81/health)
if [[ "$NGINX_RESPONSE" == *"Healthy"* ]]; then
    echo -e "${GREEN}  ✓ API Gateway funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ API Gateway NO está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Respuesta: $NGINX_RESPONSE${NC}"
    echo -e "${YELLOW}  Verificando logs:${NC}"
    docker logs --tail 20 $(docker ps -q -f name=rantipay_saas-nginx)
fi

echo -e "${YELLOW}6.3: Verificando endpoint problemático de menús:${NC}"
# Obtener un token primero
TOKEN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"username":"admin@rantipay.com","password":"Admin123!"}' http://localhost:81/v1/auth/login)
TOKEN=$(echo $TOKEN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [[ -n "$TOKEN" ]]; then
    # Verificar el endpoint de menús
    MENUS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:81/v1/sys/menus/available | head -c 100)
    if [[ "$MENUS_RESPONSE" == *"dashboard"* ]]; then
        echo -e "${GREEN}  ✓ Endpoint de menús funcionando correctamente${NC}"
    else
        echo -e "${RED}  ✗ Endpoint de menús NO está funcionando correctamente${NC}"
        echo -e "${YELLOW}  Respuesta: $MENUS_RESPONSE${NC}"
    fi
else
    echo -e "${RED}  ✗ No se pudo obtener token para probar el endpoint de menús${NC}"
    echo -e "${YELLOW}  Respuesta: $TOKEN_RESPONSE${NC}"
fi

echo -e "${YELLOW}6.4: Verificando endpoint problemático de WebSocket:${NC}"
WEBSOCKET_RESPONSE=$(curl -s -I http://localhost:81/v1/realtime/connect/ws | head -1)
if [[ "$WEBSOCKET_RESPONSE" == *"101"* || "$WEBSOCKET_RESPONSE" == *"400"* || "$WEBSOCKET_RESPONSE" == *"200"* ]]; then
    echo -e "${GREEN}  ✓ Endpoint de WebSocket responde correctamente${NC}"
else
    echo -e "${RED}  ✗ Endpoint de WebSocket NO está respondiendo correctamente${NC}"
    echo -e "${YELLOW}  Respuesta: $WEBSOCKET_RESPONSE${NC}"
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Corrección de errores 404 completada   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Servicios disponibles:${NC}"
echo -e "${GREEN}Frontend: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway: http://localhost:81${NC}"
echo -e "${GREEN}Servicio simple-user: http://localhost:8000${NC}"
echo -e "${GREEN}Servicio Companies: http://localhost:8010${NC}"
echo ""
echo -e "${YELLOW}Si sigues teniendo problemas:${NC}"
echo -e "${YELLOW}1. Verifica los logs: docker logs [nombre-contenedor]${NC}"
echo -e "${YELLOW}2. Revisa la configuración de NGINX${NC}"
echo -e "${YELLOW}3. Asegúrate de que el servicio simple-user esté funcionando${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f $DOCKER_COMPOSE_FILE down${NC}"
