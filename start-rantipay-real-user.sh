#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-hybrid-plus.yml"

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS con Usuario Real   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener cualquier instancia previa
echo -e "${YELLOW}Paso 1: Deteniendo instancias previas...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE down --remove-orphans
echo -e "${GREEN}✓ Instancias previas detenidas${NC}"
echo ""

# Paso 2: Iniciar servicios de infraestructura primero
echo -e "${YELLOW}Paso 2: Iniciando servicios de infraestructura...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d mysqld redis etcd
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al iniciar servicios de infraestructura${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 3: Esperar a que los servicios estén disponibles
echo -e "${YELLOW}Paso 3: Esperando a que los servicios de infraestructura estén disponibles...${NC}"
for i in {1..30}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysqladmin -u root -pyouShouldChangeThis ping 2>/dev/null; then
        echo -e "${GREEN}✓ MySQL está listo${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}× Tiempo de espera agotado para MySQL${NC}"
        exit 1
    fi
    echo -n "."
    sleep 1
done

for i in {1..30}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-redis) redis-cli -a youShouldChangeThis ping 2>/dev/null | grep -q "PONG"; then
        echo -e "${GREEN}✓ Redis está listo${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}× Tiempo de espera agotado para Redis${NC}"
        exit 1
    fi
    echo -n "."
    sleep 1
done

for i in {1..30}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl endpoint health 2>/dev/null; then
        echo -e "${GREEN}✓ ETCD está listo${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}× Tiempo de espera agotado para ETCD${NC}"
        exit 1
    fi
    echo -n "."
    sleep 1
done
echo ""

# Paso 4: Inicializar la base de datos
echo -e "${YELLOW}Paso 4: Inicializando base de datos...${NC}"
./init-database.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al inicializar la base de datos${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Base de datos inicializada${NC}"
echo ""

# Paso 5: Registrar servicios en ETCD
echo -e "${YELLOW}Paso 5: Inicializando ETCD...${NC}"
./init-etcd.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al inicializar ETCD${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ETCD inicializado${NC}"
echo ""

# Paso 6: Iniciar servicio User
echo -e "${YELLOW}Paso 6: Iniciando servicio User real...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d user
sleep 5  # Esperar a que el servicio inicie
echo -e "${GREEN}✓ Servicio User iniciado${NC}"
echo ""

# Paso 7: Verificar que el servicio User está funcionando
echo -e "${YELLOW}Paso 7: Verificando servicio User...${NC}"
for i in {1..30}; do
    if curl -s http://localhost:8000/v1/user/health 2>/dev/null | grep -q "OK"; then
        echo -e "${GREEN}✓ Servicio User está funcionando correctamente${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}× Tiempo de espera agotado para el servicio User${NC}"
        echo -e "${YELLOW}Revisando logs del servicio User:${NC}"
        docker logs rantipay_saas-user-1
        exit 1
    fi
    echo -n "."
    sleep 1
done
echo ""

# Paso 8: Iniciar servicio Companies
echo -e "${YELLOW}Paso 8: Iniciando servicio Companies...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d companies
sleep 5  # Esperar a que el servicio inicie
echo -e "${GREEN}✓ Servicio Companies iniciado${NC}"
echo ""

# Paso 9: Iniciar API Gateway y Frontend
echo -e "${YELLOW}Paso 9: Iniciando API Gateway y Frontend...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d nginx web
sleep 5  # Esperar a que los servicios inicien
echo -e "${GREEN}✓ API Gateway y Frontend iniciados${NC}"
echo ""

# Paso 10: Verificar todos los servicios
echo -e "${YELLOW}Paso 10: Verificando todos los servicios...${NC}"

# Verificar servicio user
echo -e "${YELLOW}Verificando servicio User:${NC}"
USER_HEALTH=$(curl -s http://localhost:8000/v1/user/health)
if [[ "$USER_HEALTH" == *"OK"* ]]; then
    echo -e "${GREEN}  ✓ Servicio User está funcionando correctamente${NC}"
    echo -e "${GREEN}    Respuesta: $USER_HEALTH${NC}"
else
    echo -e "${RED}  ✗ Servicio User no está funcionando correctamente${NC}"
    echo -e "${YELLOW}    Respuesta: $USER_HEALTH${NC}"
    echo -e "${YELLOW}  Revisando logs del servicio User:${NC}"
    docker logs --tail 20 rantipay_saas-user-1
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
echo -e "${GREEN}  - User: http://localhost:8000/v1/user${NC}"
echo -e "${GREEN}  - Companies: http://localhost:8010${NC}"
echo ""
echo -e "${YELLOW}Para iniciar sesión en el frontend:${NC}"
echo -e "${YELLOW}  - Usuario: admin@rantipay.com${NC}"
echo -e "${YELLOW}  - Contraseña: Admin123!${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f $DOCKER_COMPOSE_FILE down${NC}"
echo ""
