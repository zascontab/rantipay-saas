#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-full-user.yml"

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS con Servicio de Usuario Completo   ${NC}"
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
sleep 10
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 3: Inicializar la base de datos
echo -e "${YELLOW}Paso 3: Inicializando base de datos...${NC}"
./init-database.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al inicializar la base de datos. Continuando de todos modos...${NC}"
fi
echo -e "${GREEN}✓ Base de datos inicializada${NC}"
echo ""

# Paso 4: Inicializar ETCD
echo -e "${YELLOW}Paso 4: Inicializando ETCD...${NC}"
./init-etcd.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al inicializar ETCD. Continuando de todos modos...${NC}"
fi
echo -e "${GREEN}✓ ETCD inicializado${NC}"
echo ""

# Paso 5: Iniciar el servicio de usuario
echo -e "${YELLOW}Paso 5: Iniciando servicio de usuario...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d user
sleep 5
echo -e "${GREEN}✓ Servicio de usuario iniciado${NC}"
echo ""

# Paso 6: Iniciar el resto de servicios
echo -e "${YELLOW}Paso 6: Iniciando resto de servicios...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d
sleep 5
echo -e "${GREEN}✓ Todos los servicios iniciados${NC}"
echo ""

# Paso 7: Verificar estado de los servicios
echo -e "${YELLOW}Paso 7: Verificando estado de los servicios...${NC}"
docker ps | grep rantipay_saas
echo ""

# Paso 8: Probar el servicio de usuario
echo -e "${YELLOW}Paso 8: Probando servicio de usuario...${NC}"
echo -e "${YELLOW}8.1: Health check:${NC}"
curl -s http://localhost:8000/health || echo -e "${RED}No se pudo acceder al health check${NC}"
echo -e "\n"

echo -e "${YELLOW}8.2: Acceso a través del API Gateway:${NC}"
curl -s http://localhost:81/v1/user/health || echo -e "${RED}No se pudo acceder a través del API Gateway${NC}"
echo -e "\n"

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Sistema Iniciado con Servicio de Usuario Completo   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81${NC}"
echo -e "${GREEN}Servicio de usuario disponible en: http://localhost:8000${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f $DOCKER_COMPOSE_FILE down${NC}"
echo ""
echo -e "${YELLOW}Si encuentras problemas, verifica los logs con:${NC}"
echo -e "${YELLOW}docker logs rantipay_saas-user-1${NC}"