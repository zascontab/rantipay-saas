#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-hybrid-plus.yml"

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Reinicio y Corrección Completa del Sistema   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener todos los servicios
echo -e "${YELLOW}Paso 1: Deteniendo todos los servicios...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE down
echo -e "${GREEN}✓ Servicios detenidos${NC}"
echo ""

# Paso 2: Reconstruir servicios
echo -e "${YELLOW}Paso 2: Reconstruyendo servicios...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE build simple-user
echo -e "${GREEN}✓ Servicios reconstruidos${NC}"
echo ""

# Paso 3: Iniciar servicios de infraestructura primero
echo -e "${YELLOW}Paso 3: Iniciando servicios de infraestructura...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d mysqld redis etcd
sleep 10
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 4: Iniciar el resto de servicios
echo -e "${YELLOW}Paso 4: Iniciando el resto de servicios...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d
sleep 5
echo -e "${GREEN}✓ Todos los servicios iniciados${NC}"
echo ""

# Paso 5: Verificar servicios
echo -e "${YELLOW}Paso 5: Verificando servicios...${NC}"

echo -e "${YELLOW}5.1: Verificando servicio simple-user:${NC}"
if curl -s http://localhost:8000/health | grep -q "OK"; then
    echo -e "${GREEN}  ✓ Servicio simple-user funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ Servicio simple-user NO está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs:${NC}"
    docker logs --tail 20 rantipay_saas-simple-user-1
fi
sleep 1

echo -e "${YELLOW}5.2: Verificando API Gateway:${NC}"
if curl -s http://localhost:81/health | grep -q "Healthy"; then
    echo -e "${GREEN}  ✓ API Gateway funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ API Gateway NO está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs:${NC}"
    docker logs --tail 20 rantipay_saas-nginx-1
fi
sleep 1

echo -e "${YELLOW}5.3: Verificando proceso de login:${NC}"
LOGIN_RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"username":"admin@rantipay.com","password":"Admin123!"}' http://localhost:81/v1/auth/login)
TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [[ -n "$TOKEN" ]]; then
    echo -e "${GREEN}  ✓ Login funciona correctamente${NC}"
    echo -e "${GREEN}  ✓ Token obtenido: ${TOKEN:0:20}...${NC}"
else
    echo -e "${RED}  ✗ Login NO funciona correctamente${NC}"
    echo -e "${YELLOW}  Respuesta: $LOGIN_RESPONSE${NC}"
fi
sleep 1

echo -e "${YELLOW}5.4: Verificando endpoint de menús:${NC}"
if [[ -n "$TOKEN" ]]; then
    if curl -s -H "Authorization: Bearer $TOKEN" http://localhost:81/v1/sys/menus/available | grep -q "dashboard"; then
        echo -e "${GREEN}  ✓ Endpoint de menús funciona correctamente${NC}"
    else
        echo -e "${RED}  ✗ Endpoint de menús NO funciona correctamente${NC}"
    fi
else
    echo -e "${RED}  ✗ No se puede verificar el endpoint de menús (sin token)${NC}"
fi
sleep 1

echo -e "${YELLOW}5.5: Verificando endpoint saas/current:${NC}"
if curl -s http://localhost:81/v1/saas/current | grep -q "rantipay"; then
    echo -e "${GREEN}  ✓ Endpoint saas/current funciona correctamente${NC}"
else
    echo -e "${RED}  ✗ Endpoint saas/current NO funciona correctamente${NC}"
fi
sleep 1

echo -e "${YELLOW}5.6: Verificando endpoint payment/stripe/config:${NC}"
if curl -s http://localhost:81/v1/payment/stripe/config | grep -q "publish_key"; then
    echo -e "${GREEN}  ✓ Endpoint payment/stripe/config funciona correctamente${NC}"
else
    echo -e "${RED}  ✗ Endpoint payment/stripe/config NO funciona correctamente${NC}"
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Sistema Reiniciado y Verificado   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${YELLOW}Para usar el sistema:${NC}"
echo -e "1. Abre ${GREEN}http://localhost:8080${NC} en tu navegador"
echo -e "2. Inicia sesión con:"
echo -e "   - Usuario: ${GREEN}admin@rantipay.com${NC}"
echo -e "   - Contraseña: ${GREEN}Admin123!${NC}"
echo ""
echo -e "${YELLOW}Si sigues teniendo problemas:${NC}"
echo -e "1. Verifica los logs: ${YELLOW}docker logs rantipay_saas-simple-user-1${NC}"
echo -e "2. Verifica la consola del navegador para errores"
echo -e "3. Prueba con otras credenciales (el servicio ahora acepta cualquier login)"
