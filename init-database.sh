#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar si MySQL está en ejecución
echo -e "${YELLOW}Verificando estado de MySQL...${NC}"
if ! docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysqladmin -u root -pyouShouldChangeThis ping 2>/dev/null; then
    echo -e "${RED}Error: MySQL no está en ejecución${NC}"
    exit 1
fi

echo -e "${YELLOW}Verificando existencia de la base de datos 'kit'...${NC}"
if docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysql -u root -pyouShouldChangeThis -e "USE kit;" 2>/dev/null; then
    echo -e "${GREEN}La base de datos 'kit' ya existe${NC}"
else
    echo -e "${YELLOW}Creando base de datos 'kit'...${NC}"
    docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysql -u root -pyouShouldChangeThis -e "CREATE DATABASE IF NOT EXISTS kit;"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Base de datos 'kit' creada exitosamente${NC}"
    else
        echo -e "${RED}Error al crear la base de datos 'kit'${NC}"
        exit 1
    fi
fi

# Asegurarse de que los esquemas necesarios existan
echo -e "${YELLOW}Verificando tablas necesarias...${NC}"
TABLES_COUNT=$(docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysql -u root -pyouShouldChangeThis -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'kit';" | grep -v "COUNT" | tr -d ' ')

if [ "$TABLES_COUNT" -eq "0" ]; then
    echo -e "${YELLOW}No se encontraron tablas en la base de datos 'kit'. Los servicios go-saas/kit crearán las tablas automáticamente cuando se inicien.${NC}"
else
    echo -e "${GREEN}La base de datos 'kit' contiene $TABLES_COUNT tablas${NC}"
fi

# Verificar permisos de usuarios
echo -e "${YELLOW}Verificando permisos de usuario...${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysql -u root -pyouShouldChangeThis -e "GRANT ALL PRIVILEGES ON kit.* TO 'root'@'%';"
docker exec $(docker ps -q -f name=rantipay_saas-mysqld) mysql -u root -pyouShouldChangeThis -e "FLUSH PRIVILEGES;"

echo -e "${GREEN}La base de datos ha sido inicializada correctamente${NC}"
echo -e "${GREEN}Ahora puedes iniciar los servicios go-saas/kit con ./start-full-stack.sh${NC}"