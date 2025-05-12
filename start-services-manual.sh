#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando servicios core de go-saas/kit manualmente  ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Matar cualquier proceso existente
echo -e "${YELLOW}Deteniendo servicios existentes...${NC}"
pkill -f "bin/user" || true
pkill -f "bin/saas" || true
pkill -f "bin/sys" || true
sleep 2

# Navegar al directorio kit y compilar los servicios
echo -e "${YELLOW}Compilando servicios core...${NC}"

cd kit

# Compilar User
echo -e "${YELLOW}Compilando User...${NC}"
cd user
go mod tidy && go build -o bin/user ./cmd/user
if [ -f bin/user ]; then
    echo -e "${GREEN}✓ User compilado correctamente${NC}"
    # Copiar el binario al directorio principal
    cp bin/user ../../bin/
else
    echo -e "${RED}✗ Error al compilar User${NC}"
    exit 1
fi
cd ..

# Compilar SaaS
echo -e "${YELLOW}Compilando SaaS...${NC}"
cd saas
go mod tidy && go build -o bin/saas ./cmd/saas
if [ -f bin/saas ]; then
    echo -e "${GREEN}✓ SaaS compilado correctamente${NC}"
    # Copiar el binario al directorio principal
    cp bin/saas ../../bin/
else
    echo -e "${RED}✗ Error al compilar SaaS${NC}"
    exit 1
fi
cd ..

# Compilar Sys
echo -e "${YELLOW}Compilando Sys...${NC}"
cd sys
go mod tidy && go build -o bin/sys ./cmd/sys
if [ -f bin/sys ]; then
    echo -e "${GREEN}✓ Sys compilado correctamente${NC}"
    # Copiar el binario al directorio principal
    cp bin/sys ../../bin/
else
    echo -e "${RED}✗ Error al compilar Sys${NC}"
    exit 1
fi
cd ../..

# Asegurarse de que el directorio logs existe
mkdir -p logs

# Iniciar los servicios
echo -e "${YELLOW}Iniciando User...${NC}"
./bin/user -conf configs/user > logs/user.log 2>&1 &
USER_PID=$!
echo -e "${GREEN}✓ User iniciado con PID $USER_PID${NC}"
sleep 5

echo -e "${YELLOW}Iniciando SaaS...${NC}"
./bin/saas -conf configs/saas > logs/saas.log 2>&1 &
SAAS_PID=$!
echo -e "${GREEN}✓ SaaS iniciado con PID $SAAS_PID${NC}"
sleep 5

echo -e "${YELLOW}Iniciando Sys...${NC}"
./bin/sys -conf configs/sys > logs/sys.log 2>&1 &
SYS_PID=$!
echo -e "${GREEN}✓ Sys iniciado con PID $SYS_PID${NC}"
sleep 5

echo -e "${YELLOW}Verificando estado de los servicios...${NC}"
# Verificar que los procesos siguen en ejecución
if ps -p $USER_PID > /dev/null; then
    echo -e "${GREEN}✓ User está ejecutándose${NC}"
else
    echo -e "${RED}✗ User no está ejecutándose. Verificar logs/user.log${NC}"
fi

if ps -p $SAAS_PID > /dev/null; then
    echo -e "${GREEN}✓ SaaS está ejecutándose${NC}"
else
    echo -e "${RED}✗ SaaS no está ejecutándose. Verificar logs/saas.log${NC}"
fi

if ps -p $SYS_PID > /dev/null; then
    echo -e "${GREEN}✓ Sys está ejecutándose${NC}"
else
    echo -e "${RED}✗ Sys no está ejecutándose. Verificar logs/sys.log${NC}"
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Servicios iniciados manualmente ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "Servicios disponibles:"
echo -e "- User: http://localhost:8000"
echo -e "- SaaS: http://localhost:8001"
echo -e "- Sys: http://localhost:8002"
echo ""
echo -e "Para detener los servicios:"
echo -e "pkill -f \"bin/user\""
echo -e "pkill -f \"bin/saas\""
echo -e "pkill -f \"bin/sys\""
