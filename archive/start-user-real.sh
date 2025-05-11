#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS con User real   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener cualquier instancia previa
echo -e "${YELLOW}Paso 1: Deteniendo instancias previas...${NC}"
docker compose -f docker-compose-user-real.yml down --remove-orphans
echo -e "${GREEN}✓ Instancias previas detenidas${NC}"
echo ""

# Paso 2: Iniciar todos los servicios
echo -e "${YELLOW}Paso 2: Iniciando servicios de infraestructura...${NC}"
docker compose -f docker-compose-user-real.yml up -d mysqld redis etcd
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
echo -e "${GREEN}✓ Base de datos inicializada${NC}"
echo ""

# Paso 5: Registrar servicios en ETCD
echo -e "${YELLOW}Paso 5: Inicializando ETCD...${NC}"
./init-etcd.sh
echo -e "${GREEN}✓ ETCD inicializado${NC}"
echo ""

# Paso 6: Iniciar el servicio User
echo -e "${YELLOW}Paso 6: Iniciando servicio User real...${NC}"
docker compose -f docker-compose-user-real.yml up -d user
echo -e "${GREEN}✓ Servicio User iniciado${NC}"
echo ""

# Esperar a que el servicio User esté listo
echo -e "${YELLOW}Esperando a que el servicio User esté disponible...${NC}"
for i in {1..30}; do
    if curl -s http://localhost:8000/v1/user/health 2>/dev/null | grep -q "OK"; then
        echo -e "${GREEN}✓ User Service está listo${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}× Tiempo de espera agotado para User Service${NC}"
        echo -e "${YELLOW}Revisando logs del servicio:${NC}"
        docker logs rantipay_saas-user-1
        exit 1
    fi
    echo -n "."
    sleep 1
done
echo ""

# Paso 7: Iniciar API Gateway y Frontend
echo -e "${YELLOW}Paso 7: Iniciando API Gateway y Frontend...${NC}"
docker compose -f docker-compose-user-real.yml up -d nginx web
echo -e "${GREEN}✓ API Gateway y Frontend iniciados${NC}"
echo ""

# Paso 8: Verificar servicios
echo -e "${YELLOW}Paso 8: Verificando servicios...${NC}"
echo -e "${YELLOW}Verificando User Service:${NC}"
curl -s http://localhost:8000/v1/user/health || echo -e "${RED}No se pudo conectar al User Service${NC}"

echo -e "${YELLOW}Verificando API Gateway:${NC}"
curl -s http://localhost:81/health || echo -e "${RED}No se pudo conectar al API Gateway${NC}"

echo -e "${YELLOW}Verificando acceso a User Service a través del API Gateway:${NC}"
curl -s http://localhost:81/v1/user/health || echo -e "${RED}No se pudo acceder al User Service a través del API Gateway${NC}"

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Plataforma Rantipay SaaS con User real lista   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81/v1/${NC}"
echo -e "${GREEN}User Service real disponible en: http://localhost:8000/v1/user/${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f docker-compose-user-real.yml down${NC}"
