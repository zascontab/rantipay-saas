#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Deteniendo servicios...${NC}"

# Detener User
if [ -f ".user.pid" ]; then
    USER_PID=$(cat .user.pid)
    kill $USER_PID 2>/dev/null
    rm .user.pid
    echo -e "${GREEN}✓ Servicio User detenido${NC}"
else
    echo -e "${YELLOW}No se encontró PID para User${NC}"
fi

# Detener SaaS
if [ -f ".saas.pid" ]; then
    SAAS_PID=$(cat .saas.pid)
    kill $SAAS_PID 2>/dev/null
    rm .saas.pid
    echo -e "${GREEN}✓ Servicio SaaS detenido${NC}"
else
    echo -e "${YELLOW}No se encontró PID para SaaS${NC}"
fi

# Detener Sys
if [ -f ".sys.pid" ]; then
    SYS_PID=$(cat .sys.pid)
    kill $SYS_PID 2>/dev/null
    rm .sys.pid
    echo -e "${GREEN}✓ Servicio Sys detenido${NC}"
else
    echo -e "${YELLOW}No se encontró PID para Sys${NC}"
fi

# Detener Companies si existe
if [ -f ".companies.pid" ]; then
    COMPANIES_PID=$(cat .companies.pid)
    kill $COMPANIES_PID 2>/dev/null
    rm .companies.pid
    echo -e "${GREEN}✓ Servicio Companies detenido${NC}"
fi

echo -e "${GREEN}Todos los servicios han sido detenidos${NC}"