#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS con imágenes oficiales   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener cualquier instancia previa
echo -e "${YELLOW}Paso 1: Deteniendo instancias previas...${NC}"
docker compose -f docker-compose-official.yml down --remove-orphans
echo -e "${GREEN}✓ Instancias previas detenidas${NC}"
echo ""

# Paso 2: Iniciar servicios de infraestructura
echo -e "${YELLOW}Paso 2: Iniciando servicios de infraestructura...${NC}"
docker compose -f docker-compose-official.yml up -d mysqld redis etcd
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 3: Esperar a que los servicios estén disponibles
echo -e "${YELLOW}Paso 3: Esperando a que los servicios de infraestructura estén disponibles...${NC}"
for ((i=1; i<=30; i++)); do
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

for ((i=1; i<=30; i++)); do
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

for ((i=1; i<=30; i++)); do
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

# Paso 6: Verificar disponibilidad de imágenes
echo -e "${YELLOW}Paso 6: Verificando disponibilidad de imágenes...${NC}"
if ! docker pull goxiaoy/go-saas-kit-user:latest; then
    echo -e "${RED}× No se pudo encontrar la imagen goxiaoy/go-saas-kit-user:latest${NC}"
    echo -e "${YELLOW}Usando la imagen alternativa simple-user:debug en su lugar${NC}"
    
    # Actualizar docker-compose para usar imagen alternativa
    sed -i 's|goxiaoy/go-saas-kit-user:latest|simple-user:debug|g' docker-compose-official.yml
fi

if ! docker pull goxiaoy/go-saas-kit-frontend:latest; then
    echo -e "${RED}× No se pudo encontrar la imagen goxiaoy/go-saas-kit-frontend:latest${NC}"
    echo -e "${YELLOW}Usando la imagen alternativa goxiaoy/go-saas-kit-frontend:dev en su lugar${NC}"
    
    # Actualizar docker-compose para usar imagen alternativa
    sed -i 's|goxiaoy/go-saas-kit-frontend:latest|goxiaoy/go-saas-kit-frontend:dev|g' docker-compose-official.yml
fi
echo -e "${GREEN}✓ Verificación de imágenes completada${NC}"
echo ""

# Paso 7: Iniciar servicios básicos
echo -e "${YELLOW}Paso 7: Iniciando servicios...${NC}"
docker compose -f docker-compose-official.yml up -d
echo -e "${GREEN}✓ Servicios iniciados${NC}"
echo ""

# Paso 8: Verificar servicios
echo -e "${YELLOW}Paso 8: Verificando servicios...${NC}"
docker ps -a | grep rantipay_saas
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Plataforma Rantipay SaaS iniciada   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Para verificar los servicios, puedes usar:${NC}"
echo -e "${YELLOW}curl http://localhost:8000${NC} # Servicio User"
echo -e "${YELLOW}curl http://localhost:81/v1/${NC} # API Gateway"
echo -e "${YELLOW}curl -I http://localhost:8080${NC} # Frontend"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f docker-compose-official.yml down${NC}"
