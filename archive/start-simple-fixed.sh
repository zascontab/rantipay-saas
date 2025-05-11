#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Archivo de configuración
DOCKER_COMPOSE_FILE="docker-compose-simple-fixed.yml"

# Verificar que el archivo de Docker Compose exista
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${RED}Error: Archivo $DOCKER_COMPOSE_FILE no encontrado.${NC}"
    exit 1
fi

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS con simple-user   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener cualquier instancia previa
echo -e "${YELLOW}Paso 1: Deteniendo instancias previas...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE down || true
echo -e "${GREEN}✓ Instancias previas detenidas${NC}"
echo ""

# Paso 2: Limpiar volúmenes antiguos
echo -e "${YELLOW}Paso 2: Limpiando volúmenes antiguos...${NC}"
docker volume rm rantipay_saas_etcd_data 2>/dev/null || true
docker volume rm rantipay_saas_mysql_data 2>/dev/null || true
echo -e "${GREEN}✓ Volúmenes antiguos limpiados${NC}"
echo ""

# Verificar si la imagen simple-user:debug existe
echo -e "${YELLOW}Verificando imagen simple-user:debug...${NC}"
if ! docker images | grep -q "simple-user" | grep -q "debug"; then
    echo -e "${YELLOW}Construyendo imagen simple-user:debug...${NC}"
    cd simple-user
    docker build -t simple-user:debug -f Dockerfile.debug .
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error al construir la imagen simple-user:debug${NC}"
        exit 1
    fi
    cd ..
fi
echo -e "${GREEN}✓ Imagen simple-user:debug disponible${NC}"
echo ""

# Paso 3: Inicio de servicios de infraestructura
echo -e "${YELLOW}Paso 3: Iniciando servicios de infraestructura...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d mysqld redis etcd
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar servicios de infraestructura${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 4: Esperar a que los servicios estén disponibles
echo -e "${YELLOW}Paso 4: Esperando a que los servicios de infraestructura estén disponibles...${NC}"
for i in {1..20}; do
    if docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysqladmin -u root -pyouShouldChangeThis ping 2>/dev/null; then
        echo -e "${GREEN}✓ MySQL está listo${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${RED}× Tiempo de espera agotado para MySQL${NC}"
        docker logs rantipay_saas-mysqld-1
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
        docker logs rantipay_saas-redis-1
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
        docker logs rantipay_saas-etcd-1
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Paso 5: Inicializar la base de datos
echo -e "${YELLOW}Paso 5: Inicializando base de datos...${NC}"
./init-database.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al inicializar la base de datos${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Base de datos inicializada${NC}"
echo ""

# Paso 6: Registrar servicios en ETCD
echo -e "${YELLOW}Paso 6: Inicializando ETCD...${NC}"
./init-etcd.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al inicializar ETCD${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ETCD inicializado${NC}"
echo ""

# Paso 7: Iniciar servicio user
echo -e "${YELLOW}Paso 7: Iniciando servicio user simplificado...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d user
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar el servicio user${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicio user iniciado${NC}"
echo ""

# Esperar a que el servicio user esté listo
echo -e "${YELLOW}Esperando a que el servicio user esté disponible...${NC}"
for i in {1..15}; do
    if curl -s http://localhost:8000 2>/dev/null | grep -q "Hello"; then
        echo -e "${GREEN}✓ User service está listo${NC}"
        break
    fi
    if [ $i -eq 15 ]; then
        echo -e "${RED}× Tiempo de espera agotado para User service${NC}"
        docker logs rantipay_saas-user-1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Paso 8: Iniciar API Gateway y Frontend
echo -e "${YELLOW}Paso 8: Iniciando API Gateway y Frontend...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d nginx web
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar API Gateway y Frontend${NC}"
    exit 1
fi
echo -e "${GREEN}✓ API Gateway y Frontend iniciados${NC}"
echo ""

# Paso 9: Verificar todos los servicios
echo -e "${YELLOW}Paso 9: Verificando estado de los servicios...${NC}"
sleep 5  # Dar tiempo a que los servicios se inicien completamente

# Verificar servicio user
echo -e "${YELLOW}Verificando servicio user:${NC}"
RESULT=$(curl -s http://localhost:8000 2>/dev/null)
if echo $RESULT | grep -q "Hello"; then
    echo -e "${GREEN}  ✓ User Service (simple) está funcionando correctamente${NC}"
    echo -e "${GREEN}    Respuesta: $(echo $RESULT | head -n 1)${NC}"
else
    echo -e "${RED}  ✗ User Service no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Mostrando logs del servicio user:${NC}"
    docker logs --tail 20 rantipay_saas-user-1 2>/dev/null || echo "No se pudieron obtener logs"
fi

# Verificar API Gateway
echo -e "${YELLOW}Verificando API Gateway:${NC}"
RESULT=$(curl -s http://localhost:81/health 2>/dev/null)
if echo $RESULT | grep -q "Gateway" || echo $RESULT | grep -q "Healthy"; then
    echo -e "${GREEN}  ✓ API Gateway está funcionando correctamente${NC}"
    echo -e "${GREEN}    Respuesta: $(echo $RESULT | head -n 1)${NC}"
else
    echo -e "${RED}  ✗ API Gateway no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Mostrando logs del API Gateway:${NC}"
    docker logs --tail 15 rantipay_saas-nginx-1 2>/dev/null || echo "No se pudieron obtener logs"
fi

# Verificar API Gateway - Proxy al servicio user
echo -e "${YELLOW}Verificando API Gateway - Proxy al servicio user:${NC}"
RESULT=$(curl -s http://localhost:81/v1/ 2>/dev/null)
if echo $RESULT | grep -q "Hello"; then
    echo -e "${GREEN}  ✓ API Gateway está correctamente redirigiendo al servicio user${NC}"
    echo -e "${GREEN}    Respuesta: $(echo $RESULT | head -n 1)${NC}"
else
    echo -e "${RED}  ✗ API Gateway no está redirigiendo correctamente al servicio user${NC}"
    echo -e "${YELLOW}  Mostrando logs del API Gateway:${NC}"
    docker logs --tail 15 rantipay_saas-nginx-1 2>/dev/null || echo "No se pudieron obtener logs"
fi

# Verificar Frontend
echo -e "${YELLOW}Verificando Frontend:${NC}"
RESULT=$(curl -s -I http://localhost:8080 2>/dev/null)
if echo $RESULT | grep -q "200 OK"; then
    echo -e "${GREEN}  ✓ Frontend está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ Frontend no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Mostrando logs del Frontend:${NC}"
    docker logs --tail 15 rantipay_saas-web-1 2>/dev/null || echo "No se pudieron obtener logs"
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Plataforma Rantipay SaaS lista para usar   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81/v1/${NC}"
echo -e "${GREEN}Servicio User simplificado disponible en: http://localhost:8000${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f $DOCKER_COMPOSE_FILE down${NC}"
echo ""
echo -e "${YELLOW}Para ver logs de un servicio específico:${NC}"
echo -e "${YELLOW}docker logs -f rantipay_saas-[nombre_servicio]-1${NC}"
echo -e "${YELLOW}Ejemplo: docker logs -f rantipay_saas-user-1${NC}"