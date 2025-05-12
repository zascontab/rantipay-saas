#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Buscando archivos Go en kit/user   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

echo -e "${YELLOW}Buscando archivos Go en directorios principales:${NC}"
find kit/user -maxdepth 1 -name "*.go" | sort
echo ""

echo -e "${YELLOW}Buscando archivos Go en el directorio cmd:${NC}"
find kit/user/cmd -name "*.go" | sort
echo ""

echo -e "${YELLOW}Buscando punto de entrada main.go:${NC}"
find kit/user -name "main.go" | sort
echo ""

echo -e "${YELLOW}Examinando la estructura del directorio cmd:${NC}"
ls -la kit/user/cmd/
echo ""

echo -e "${YELLOW}Verificando el contenido de kit/user/cmd:${NC}"
find kit/user/cmd -type f | sort
echo ""
