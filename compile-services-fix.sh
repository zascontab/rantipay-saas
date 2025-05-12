#!/bin/bash

# Colors for messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Compilando servicios core de go-saas/kit (ajustado)   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Buscar los servicios principales reales
echo -e "${YELLOW}Buscando ubicación de servicios principales...${NC}"
USER_MAIN=$(find kit -name "main.go" -path "*/user/*" | head -1)
SAAS_MAIN=$(find kit -name "main.go" -path "*/saas/*" | head -1)
SYS_MAIN=$(find kit -name "main.go" -path "*/sys/*" | head -1)

# Mostrar las ubicaciones encontradas
echo -e "User main: ${USER_MAIN:-No encontrado}"
echo -e "SaaS main: ${SAAS_MAIN:-No encontrado}"
echo -e "Sys main: ${SYS_MAIN:-No encontrado}"
echo ""

# Crear directorio bin si no existe
mkdir -p bin

# Compilar User
if [ -n "$USER_MAIN" ]; then
    echo -e "${YELLOW}Compilando servicio User...${NC}"
    USER_DIR=$(dirname "$USER_MAIN")
    cd $USER_DIR
    # Obtener el nombre del directorio actual
    CURRENT_DIR=$(basename $(pwd))
    echo -e "${YELLOW}Directorio actual: $CURRENT_DIR${NC}"
    
    # Compilar y guardar directamente en el directorio bin
    go build -o ../../../../bin/user
    if [ $? -ne 0 ]; then
        echo -e "${RED}× Error al compilar el servicio User${NC}"
    else
        echo -e "${GREEN}✓ Servicio User compilado correctamente${NC}"
        # Verificar que el binario existe
        ls -la ../../../../bin/user
    fi
    cd -
fi

# Compilar SaaS
if [ -n "$SAAS_MAIN" ]; then
    echo -e "${YELLOW}Compilando servicio SaaS...${NC}"
    SAAS_DIR=$(dirname "$SAAS_MAIN")
    cd $SAAS_DIR
    # Obtener el nombre del directorio actual
    CURRENT_DIR=$(basename $(pwd))
    echo -e "${YELLOW}Directorio actual: $CURRENT_DIR${NC}"
    
    # Compilar y guardar directamente en el directorio bin
    go build -o ../../../../bin/saas
    if [ $? -ne 0 ]; then
        echo -e "${RED}× Error al compilar el servicio SaaS${NC}"
    else
        echo -e "${GREEN}✓ Servicio SaaS compilado correctamente${NC}"
        # Verificar que el binario existe
        ls -la ../../../../bin/saas
    fi
    cd -
fi

# Compilar Sys
if [ -n "$SYS_MAIN" ]; then
    echo -e "${YELLOW}Compilando servicio Sys...${NC}"
    SYS_DIR=$(dirname "$SYS_MAIN")
    cd $SYS_DIR
    # Obtener el nombre del directorio actual
    CURRENT_DIR=$(basename $(pwd))
    echo -e "${YELLOW}Directorio actual: $CURRENT_DIR${NC}"
    
    # Compilar y guardar directamente en el directorio bin
    go build -o ../../../../bin/sys
    if [ $? -ne 0 ]; then
        echo -e "${RED}× Error al compilar el servicio Sys${NC}"
    else
        echo -e "${GREEN}✓ Servicio Sys compilado correctamente${NC}"
        # Verificar que el binario existe
        ls -la ../../../../bin/sys
    fi
    cd -
fi

# Verificar que todos los binarios existen
echo -e "${YELLOW}Verificando que todos los binarios existen...${NC}"
ls -la bin/

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Compilación ajustada completada   ${NC}"
echo -e "${GREEN}==============================================${NC}"
