#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Compilando Servicio de Usuario Completo   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Verificar que el directorio kit/user existe
if [ ! -d "kit/user" ]; then
    echo -e "${RED}Error: No se encontró el directorio kit/user${NC}"
    echo -e "${YELLOW}Asegúrate de estar en el directorio raíz del proyecto rantipay_saas${NC}"
    exit 1
fi

# Paso 2: Verificar que Go está instalado
if ! command -v go &> /dev/null; then
    echo -e "${RED}Error: Go no está instalado${NC}"
    echo -e "${YELLOW}Por favor instala Go 1.18 o superior${NC}"
    exit 1
fi

# Paso 3: Crear directorio para binarios si no existe
mkdir -p kit/user/bin

# Paso 4: Navegar al directorio kit/user y compilar
echo -e "${YELLOW}Compilando servicio de usuario...${NC}"
cd kit/user
go mod tidy
make build

# Verificar si la compilación fue exitosa
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: La compilación falló${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Servicio de usuario compilado exitosamente${NC}"
echo -e "${YELLOW}El binario se encuentra en kit/user/bin/user${NC}"

# Paso 5: Volver al directorio raíz
cd ../..

# Paso 6: Construir imagen Docker
echo -e "${YELLOW}Construyendo imagen Docker...${NC}"
docker build -t go-saas-kit-user:latest -f user-dockerfile .

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: La construcción de la imagen Docker falló${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Imagen Docker go-saas-kit-user:latest construida exitosamente${NC}"
echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Servicio de Usuario Compilado y Empaquetado   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${YELLOW}Ahora puedes actualizar el docker-compose para usar este servicio${NC}"
echo -e "${YELLOW}Ejecuta './update-docker-compose.sh' para actualizar automáticamente${NC}"