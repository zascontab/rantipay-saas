#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS con servicios completos   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Archivo de configuración
DOCKER_COMPOSE_FILE="docker-compose-full-services.yml"

# Verificar que el archivo de Docker Compose exista
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${RED}Error: Archivo $DOCKER_COMPOSE_FILE no encontrado.${NC}"
    exit 1
fi

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

# Paso 3: Verificar imágenes
echo -e "${YELLOW}Paso 3: Verificando imágenes...${NC}"
if ! docker images | grep -q "go-saas-kit-user"; then
    echo -e "${RED}Error: Imagen go-saas-kit-user no encontrada${NC}"
    echo -e "${YELLOW}Ejecute primero ./build-services.sh para construir las imágenes${NC}"
    exit 1
fi

if ! docker images | grep -q "go-saas-kit-saas"; then
    echo -e "${RED}Error: Imagen go-saas-kit-saas no encontrada${NC}"
    echo -e "${YELLOW}Ejecute primero ./build-services.sh para construir las imágenes${NC}"
    exit 1
fi

if ! docker images | grep -q "go-saas-kit-sys"; then
    echo -e "${RED}Error: Imagen go-saas-kit-sys no encontrada${NC}"
    echo -e "${YELLOW}Ejecute primero ./build-services.sh para construir las imágenes${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Imágenes verificadas${NC}"
echo ""

# Paso 4: Inicio de servicios de infraestructura
echo -e "${YELLOW}Paso 4: Iniciando servicios de infraestructura...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d mysqld redis etcd
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar servicios de infraestructura${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 5: Esperar a que los servicios estén disponibles
echo -e "${YELLOW}Paso 5: Esperando a que los servicios de infraestructura estén disponibles...${NC}"
for i in {1..20}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysqladmin -u root -pyouShouldChangeThis ping 2>/dev/null; then
        echo -e "${GREEN}✓ MySQL está listo${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${RED}× Tiempo de espera agotado para MySQL${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done

for i in {1..20}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-redis) redis-cli -a youShouldChangeThis ping 2>/dev/null | grep -q "PONG"; then
        echo -e "${GREEN}✓ Redis está listo${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${RED}× Tiempo de espera agotado para Redis${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done

for i in {1..20}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl endpoint health 2>/dev/null; then
        echo -e "${GREEN}✓ ETCD está listo${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${RED}× Tiempo de espera agotado para ETCD${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Paso 6: Inicializar la base de datos
echo -e "${YELLOW}Paso 6: Inicializando base de datos...${NC}"
./init-database.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al inicializar la base de datos${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Base de datos inicializada${NC}"
echo ""

# Paso 7: Registrar servicios en ETCD
echo -e "${YELLOW}Paso 7: Inicializando ETCD...${NC}"
./init-etcd.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al inicializar ETCD${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ETCD inicializado${NC}"
echo ""

# Paso 8: Iniciar servicio user
echo -e "${YELLOW}Paso 8: Iniciando servicio user...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d user
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar el servicio user${NC}"
    exit 1
fi
sleep 10  # Esperar a que el servicio inicie
echo -e "${GREEN}✓ Servicio user iniciado${NC}"
echo ""

# Paso 9: Iniciar servicio saas
echo -e "${YELLOW}Paso 9: Iniciando servicio saas...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d saas
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar el servicio saas${NC}"
    exit 1
fi
sleep 10  # Esperar a que el servicio inicie
echo -e "${GREEN}✓ Servicio saas iniciado${NC}"
echo ""

# Paso 10: Iniciar servicio sys
echo -e "${YELLOW}Paso 10: Iniciando servicio sys...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d sys
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar el servicio sys${NC}"
    exit 1
fi
sleep 10  # Esperar a que el servicio inicie
echo -e "${GREEN}✓ Servicio sys iniciado${NC}"
echo ""

# Paso 11: Iniciar API Gateway y Frontend
echo -e "${YELLOW}Paso 11: Iniciando API Gateway y Frontend...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d nginx web
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar API Gateway y Frontend${NC}"
    exit 1
fi
sleep 10  # Esperar a que los servicios inicien
echo -e "${GREEN}✓ API Gateway y Frontend iniciados${NC}"
echo ""

# Paso 12: Verificar todos los servicios
echo -e "${YELLOW}Paso 12: Verificando estado de los servicios...${NC}"

# Verificar servicio user
echo -e "${YELLOW}Verificando servicio user:${NC}"
if curl -s http://localhost:8000/v1/user/health 2>/dev/null | grep -q "OK"; then
    echo -e "${GREEN}  ✓ User Service está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ User Service no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Mostrando logs del servicio user:${NC}"
    docker logs rantipay_saas-user-1 2>/dev/null || echo "No se pudieron obtener logs"
fi

# Verificar servicio saas
echo -e "${YELLOW}Verificando servicio saas:${NC}"
if curl -s http://localhost:8002/v1/saas/health 2>/dev/null | grep -q "OK"; then
    echo -e "${GREEN}  ✓ SaaS Service está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ SaaS Service no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Mostrando logs del servicio saas:${NC}"
   docker logs rantipay_saas-saas-1 2>/dev/null || echo "No se pudieron obtener logs"
fi

# Verificar servicio sys
echo -e "${YELLOW}Verificando servicio sys:${NC}"
if curl -s http://localhost:8003/v1/sys/health 2>/dev/null | grep -q "OK"; then
   echo -e "${GREEN}  ✓ Sys Service está funcionando correctamente${NC}"
else
   echo -e "${RED}  ✗ Sys Service no está funcionando correctamente${NC}"
   echo -e "${YELLOW}  Mostrando logs del servicio sys:${NC}"
   docker logs rantipay_saas-sys-1 2>/dev/null || echo "No se pudieron obtener logs"
fi

# Verificar API Gateway
echo -e "${YELLOW}Verificando API Gateway:${NC}"
if curl -s http://localhost:81/health 2>/dev/null | grep -q "Healthy"; then
   echo -e "${GREEN}  ✓ API Gateway está funcionando correctamente${NC}"
else
   echo -e "${RED}  ✗ API Gateway no está funcionando correctamente${NC}"
   echo -e "${YELLOW}  Mostrando logs del API Gateway:${NC}"
   docker logs rantipay_saas-nginx-1 2>/dev/null || echo "No se pudieron obtener logs"
fi

# Verificar Frontend
echo -e "${YELLOW}Verificando Frontend:${NC}"
if curl -s -I http://localhost:8080 2>/dev/null | grep -q "200 OK"; then
   echo -e "${GREEN}  ✓ Frontend está funcionando correctamente${NC}"
else
   echo -e "${RED}  ✗ Frontend no está funcionando correctamente${NC}"
   echo -e "${YELLOW}  Mostrando logs del Frontend:${NC}"
   docker logs rantipay_saas-web-1 2>/dev/null || echo "No se pudieron obtener logs"
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Plataforma Rantipay SaaS lista para usar   ${NC}"
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
echo -e "${YELLOW}Para ver logs de un servicio específico:${NC}"
echo -e "${YELLOW}docker logs -f rantipay_saas-[nombre_servicio]-1${NC}"
echo -e "${YELLOW}Ejemplo: docker logs -f rantipay_saas-user-1${NC}"
