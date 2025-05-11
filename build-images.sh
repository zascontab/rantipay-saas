#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Construcción de imágenes Docker para go-saas/kit   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Verificar si el código fuente existe
if [ ! -d "kit/user" ] || [ ! -d "kit/saas" ] || [ ! -d "kit/sys" ]; then
    echo -e "${RED}Error: No se encontró el código fuente de go-saas/kit${NC}"
    echo -e "${YELLOW}Asegúrate de estar en el directorio raíz del proyecto y de haber clonado el repositorio go-saas/kit${NC}"
    exit 1
fi

# Copiar los Dockerfiles a los directorios correspondientes
echo -e "${YELLOW}Copiando Dockerfiles a los directorios correspondientes...${NC}"
cp kit/user/Dockerfile.simple kit/user/Dockerfile.build
cp kit/saas/Dockerfile.simple kit/saas/Dockerfile.build
cp kit/sys/Dockerfile.simple kit/sys/Dockerfile.build
echo -e "${GREEN}✓ Dockerfiles copiados${NC}"
echo ""

# Construir imagen para el servicio user
echo -e "${YELLOW}Construyendo imagen para el servicio user...${NC}"
cd kit/user
docker build -t go-saas-kit-user:latest -f Dockerfile.build .
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al construir la imagen para el servicio user${NC}"
    cd ../..
    exit 1
fi
cd ../..
echo -e "${GREEN}✓ Imagen go-saas-kit-user:latest construida correctamente${NC}"
echo ""

# Construir imagen para el servicio saas
echo -e "${YELLOW}Construyendo imagen para el servicio saas...${NC}"
cd kit/saas
docker build -t go-saas-kit-saas:latest -f Dockerfile.build .
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al construir la imagen para el servicio saas${NC}"
    cd ../..
    exit 1
fi
cd ../..
echo -e "${GREEN}✓ Imagen go-saas-kit-saas:latest construida correctamente${NC}"
echo ""

# Construir imagen para el servicio sys
echo -e "${YELLOW}Construyendo imagen para el servicio sys...${NC}"
cd kit/sys
docker build -t go-saas-kit-sys:latest -f Dockerfile.build .
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al construir la imagen para el servicio sys${NC}"
    cd ../..
    exit 1
fi
cd ../..
echo -e "${GREEN}✓ Imagen go-saas-kit-sys:latest construida correctamente${NC}"
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Imágenes Docker construidas correctamente   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Ahora puedes iniciar los servicios go-saas/kit con:${NC}"
echo -e "${YELLOW}./setup-all-in-one.sh${NC}"
echo ""