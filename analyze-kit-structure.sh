#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Analizando la estructura de go-saas/kit   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

echo -e "${YELLOW}Estructura de directorios principales:${NC}"
ls -la kit/
echo ""

echo -e "${YELLOW}Estructura del directorio kit/user:${NC}"
ls -la kit/user/
echo ""

echo -e "${YELLOW}Verificando archivos de configuración:${NC}"
find kit/ -name "config.yaml" -o -name "*.yaml" | sort
echo ""

echo -e "${YELLOW}Verificando Makefile:${NC}"
if [ -f kit/user/Makefile ]; then
    echo -e "${GREEN}Makefile encontrado. Contenido:${NC}"
    cat kit/user/Makefile
else
    echo -e "${RED}Makefile no encontrado${NC}"
fi
echo ""

echo -e "${YELLOW}Verificando archivo go.mod:${NC}"
if [ -f kit/user/go.mod ]; then
    echo -e "${GREEN}go.mod encontrado. Contenido:${NC}"
    cat kit/user/go.mod
else
    echo -e "${RED}go.mod no encontrado${NC}"
fi
echo ""

echo -e "${YELLOW}Verificando la estructura de los directorios de configuración:${NC}"
find kit/ -name "configs" -type d | sort
echo ""

echo -e "${YELLOW}Verificando archivos dentro de los directorios de configuración:${NC}"
find kit/ -path "*/configs/*" -type f | sort
echo ""

echo -e "${YELLOW}Analizando la estructura de despliegue:${NC}"
find kit/ -name "deploy" -type d | sort
find kit/ -path "*/deploy/*" -type f | sort
echo ""
