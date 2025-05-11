#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Verificando estado de los servicios...${NC}"

echo -e "${YELLOW}Infraestructura:${NC}"
echo -e "${YELLOW}1. ETCD:${NC}"
if docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl endpoint health 2>/dev/null; then
    echo -e "${GREEN}  ✓ ETCD está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ ETCD no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs...${NC}"
    docker logs --tail 15 $(docker ps -q -f name=rantipay_saas-etcd)
fi

echo -e "${YELLOW}2. MySQL:${NC}"
if docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysqladmin -u root -pyouShouldChangeThis ping 2>/dev/null; then
    echo -e "${GREEN}  ✓ MySQL está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ MySQL no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs...${NC}"
    docker logs --tail 15 $(docker ps -q -f name=rantipay_saas-mysqld)
fi

echo -e "${YELLOW}3. Redis:${NC}"
if docker exec $(docker ps -q -f name=rantipay_saas-redis) redis-cli -a youShouldChangeThis ping 2>/dev/null | grep -q "PONG"; then
    echo -e "${GREEN}  ✓ Redis está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ Redis no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs...${NC}"
    docker logs --tail 15 $(docker ps -q -f name=rantipay_saas-redis)
fi

echo -e "${YELLOW}Servicios:${NC}"
echo -e "${YELLOW}1. User Service:${NC}"
# Probamos con múltiples endpoints posibles
if curl -s http://localhost:8000/health 2>/dev/null | grep -q "OK"; then
    echo -e "${GREEN}  ✓ User Service está funcionando correctamente (endpoint /health)${NC}"
elif curl -s http://localhost:8000/v1/user/health 2>/dev/null | grep -q "OK"; then
    echo -e "${GREEN}  ✓ User Service está funcionando correctamente (endpoint /v1/user/health)${NC}"
elif curl -s http://localhost:8000 2>/dev/null | grep -q "simple"; then
    echo -e "${GREEN}  ✓ User Service (simple) está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ User Service no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs...${NC}"
    docker logs --tail 20 $(docker ps -q -f name=rantipay_saas-user)
fi

echo -e "${YELLOW}2. SaaS Service:${NC}"
if curl -s http://localhost:8002/health 2>/dev/null | grep -q "OK"; then
    echo -e "${GREEN}  ✓ SaaS Service está funcionando correctamente (endpoint /health)${NC}"
elif curl -s http://localhost:8002/v1/saas/health 2>/dev/null | grep -q "OK"; then
    echo -e "${GREEN}  ✓ SaaS Service está funcionando correctamente (endpoint /v1/saas/health)${NC}"
else
    echo -e "${RED}  ✗ SaaS Service no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs...${NC}"
    docker logs --tail 20 $(docker ps -q -f name=rantipay_saas-saas)
fi

echo -e "${YELLOW}3. Sys Service:${NC}"
if curl -s http://localhost:8003/health 2>/dev/null | grep -q "OK"; then
    echo -e "${GREEN}  ✓ Sys Service está funcionando correctamente (endpoint /health)${NC}"
elif curl -s http://localhost:8003/v1/sys/health 2>/dev/null | grep -q "OK"; then
    echo -e "${GREEN}  ✓ Sys Service está funcionando correctamente (endpoint /v1/sys/health)${NC}"
else
    echo -e "${RED}  ✗ Sys Service no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs...${NC}"
    docker logs --tail 20 $(docker ps -q -f name=rantipay_saas-sys)
fi

echo -e "${YELLOW}Gateway y Frontend:${NC}"
echo -e "${YELLOW}1. NGINX Gateway:${NC}"
if curl -s http://localhost:81/health 2>/dev/null | grep -q "Gateway"; then
    echo -e "${GREEN}  ✓ NGINX Gateway está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ NGINX Gateway no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs...${NC}"
    docker logs --tail 15 $(docker ps -q -f name=rantipay_saas-nginx)
fi

echo -e "${YELLOW}2. Frontend:${NC}"
if curl -s -I http://localhost:8080 2>/dev/null | grep -q "200 OK"; then
    echo -e "${GREEN}  ✓ Frontend está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ Frontend no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs...${NC}"
    docker logs --tail 15 $(docker ps -q -f name=rantipay_saas-web)
fi

echo -e "${YELLOW}Verificando las conexiones entre servicios:${NC}"
echo -e "${YELLOW}1. Verificando red Docker:${NC}"
docker network inspect rantipay_saas_app-network 2>/dev/null | grep -q "Containers" && echo -e "${GREEN}  ✓ Red Docker existe${NC}" || echo -e "${RED}  ✗ Red Docker no existe${NC}"

echo -e "${YELLOW}2. Conexiones desde User service:${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-user) ping -c 1 mysqld 2>/dev/null && echo -e "${GREEN}  ✓ User → MySQL funciona${NC}" || echo -e "${RED}  ✗ User → MySQL no funciona${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-user) ping -c 1 redis 2>/dev/null && echo -e "${GREEN}  ✓ User → Redis funciona${NC}" || echo -e "${RED}  ✗ User → Redis no funciona${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-user) ping -c 1 etcd 2>/dev/null && echo -e "${GREEN}  ✓ User → ETCD funciona${NC}" || echo -e "${RED}  ✗ User → ETCD no funciona${NC}"

echo -e "${YELLOW}Acciones comunes para solucionar problemas:${NC}"
echo -e "${GREEN}1. Reiniciar un servicio específico:${NC}"
echo -e "   docker compose -f docker-compose-local.yml restart [servicio]"
echo -e "${GREEN}2. Ver logs de un servicio:${NC}"
echo -e "   docker logs -f rantipay_saas-[servicio]-1"
echo -e "${GREEN}3. Reiniciar todo el stack:${NC}"
echo -e "   ./start-local.sh"
echo -e "${GREEN}4. Acceder a un contenedor para depuración:${NC}"
echo -e "   docker exec -it rantipay_saas-[servicio]-1 /bin/bash"
echo -e "${GREEN}5. Verificar estado de ETCD:${NC}"
echo -e "   docker exec rantipay_saas-etcd-1 etcdctl get /services/user/1 --print-value-only"
echo -e "${GREEN}6. Verificar la base de datos:${NC}"
echo -e "   docker exec -it rantipay_saas-mysqld-1 mysql -u root -pyouShouldChangeThis kit"
echo -e "${GREEN}7. Reiniciar el registro de servicios en ETCD:${NC}"
echo -e "   ./init-etcd.sh"