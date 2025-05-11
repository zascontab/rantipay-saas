#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Prueba aislada del servicio User real   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener cualquier instancia previa
echo -e "${YELLOW}Paso 1: Deteniendo instancias previas...${NC}"
docker compose -f docker-compose-user-test.yml down --remove-orphans
echo -e "${GREEN}✓ Instancias previas detenidas${NC}"
echo ""

# Paso 2: Iniciar servicios de infraestructura
echo -e "${YELLOW}Paso 2: Iniciando servicios de infraestructura...${NC}"
docker compose -f docker-compose-user-test.yml up -d mysqld redis etcd
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

# Paso 6: Iniciar el servicio User en modo de depuración
echo -e "${YELLOW}Paso 6: Iniciando servicio User en modo de depuración...${NC}"
docker compose -f docker-compose-user-test.yml up -d user
echo -e "${GREEN}✓ Servicio User iniciado en modo de depuración${NC}"
echo ""

# Mostrar los logs del servicio User
echo -e "${YELLOW}Logs del servicio User:${NC}"
sleep 3
docker logs rantipay_saas-user-1
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Prueba del servicio User completada   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${YELLOW}Puedes ver los logs completos con:${NC}"
echo -e "${YELLOW}docker logs -f rantipay_saas-user-1${NC}"
