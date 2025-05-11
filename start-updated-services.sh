#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-full-services-updated.yml"

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS con servicios completos (updated)   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener cualquier instancia previa
echo -e "${YELLOW}Paso 1: Deteniendo instancias previas...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE down 2>/dev/null || true
echo -e "${GREEN}✓ Instancias previas detenidas${NC}"
echo ""

# Paso 2: Limpiar volúmenes antiguos
echo -e "${YELLOW}Paso 2: Limpiando volúmenes antiguos...${NC}"
docker volume rm rantipay_saas_etcd_data 2>/dev/null || true
docker volume rm rantipay_saas_mysql_data 2>/dev/null || true
echo -e "${GREEN}✓ Volúmenes antiguos limpiados${NC}"
echo ""

# Paso 3: Iniciar servicios de infraestructura primero
echo -e "${YELLOW}Paso 3: Iniciando servicios de infraestructura...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d mysqld redis etcd
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 4: Esperar a que los servicios estén listos
echo -e "${YELLOW}Paso 4: Esperando a que los servicios de infraestructura estén disponibles...${NC}"
for i in {1..30}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysqladmin -u root -pyouShouldChangeThis ping 2>/dev/null; then
        echo -e "${GREEN}✓ MySQL está listo${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}× Tiempo de espera agotado para MySQL${NC}"
    else
        echo -n "."
        sleep 1
    fi
done

# Paso 5: Inicializar la base de datos
echo -e "${YELLOW}Paso 5: Inicializando base de datos...${NC}"
./init-database.sh
echo -e "${GREEN}✓ Base de datos inicializada${NC}"
echo ""

# Paso 6: Registrar servicios en ETCD
echo -e "${YELLOW}Paso 6: Inicializando ETCD...${NC}"
./init-etcd.sh
echo -e "${GREEN}✓ ETCD inicializado${NC}"
echo ""

# Paso 7: Iniciar servicio user
echo -e "${YELLOW}Paso 7: Iniciando servicio user...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d user
sleep 5
echo -e "${GREEN}✓ Servicio user iniciado${NC}"
echo ""

# Paso 8: Ver logs del servicio user
echo -e "${YELLOW}Paso 8: Verificando logs del servicio user...${NC}"
docker logs rantipay_saas-user-1
echo ""

# Paso 9: Si el user service está funcionando, iniciar los demás servicios
echo -e "${YELLOW}Paso 9: Iniciando servicios restantes...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d
echo -e "${GREEN}✓ Todos los servicios iniciados${NC}"
echo ""

# Paso 10: Verificar estado de los servicios
echo -e "${YELLOW}Paso 10: Verificando estado de los servicios...${NC}"
docker ps -a | grep rantipay_saas
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Plataforma Rantipay SaaS iniciada   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81/v1/${NC}"
echo -e "${GREEN}Servicios individuales disponibles en:${NC}"
echo -e "${GREEN}  - User: http://localhost:8000/v1/user/${NC}"
echo -e "${GREEN}  - SaaS: http://localhost:8002/v1/saas/${NC}"
echo -e "${GREEN}  - Sys: http://localhost:8003/v1/sys/${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f $DOCKER_COMPOSE_FILE down${NC}"
echo ""
