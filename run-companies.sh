#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Compilando servicio Companies...${NC}"
cd companies-service/cmd/server
go mod tidy
go build -o ../../bin/companies
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al compilar el servicio Companies${NC}"
    exit 1
fi
cd ../../

echo -e "${GREEN}✓ Servicio Companies compilado correctamente${NC}"
echo -e "${YELLOW}Iniciando servicio Companies...${NC}"
./bin/companies > ../logs/companies.log 2>&1 &
COMPANIES_PID=$!
echo $COMPANIES_PID > ../.companies.pid

echo -e "${GREEN}✓ Servicio Companies iniciado con PID $COMPANIES_PID${NC}"
echo -e "${GREEN}Servicio disponible en: http://localhost:8010${NC}"
echo -e "${YELLOW}Para detener el servicio:${NC}"
echo -e "${GREEN}kill $COMPANIES_PID${NC}"