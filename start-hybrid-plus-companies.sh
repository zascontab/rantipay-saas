#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS con enfoque híbrido expandido   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener cualquier instancia previa
echo -e "${YELLOW}Paso 1: Deteniendo instancias previas...${NC}"
docker compose -f docker-compose-hybrid-plus.yml down --remove-orphans
echo -e "${GREEN}✓ Instancias previas detenidas${NC}"
echo ""

# Paso 2: Iniciar todos los servicios
echo -e "${YELLOW}Paso 2: Iniciando todos los servicios...${NC}"
docker compose -f docker-compose-hybrid-plus.yml up -d
echo -e "${GREEN}✓ Todos los servicios iniciados${NC}"
echo ""

echo -e "${YELLOW}Esperando a que los servicios estén disponibles...${NC}"
sleep 10

# Paso 3: Verificar estado de los servicios
echo -e "${YELLOW}Paso 3: Verificando estado de los servicios...${NC}"
docker ps -a | grep rantipay_saas
echo ""

# Paso 4: Probar servicios
echo -e "${YELLOW}Paso 4: Probando servicios...${NC}"
echo -e "${YELLOW}4.1: Servicio User:${NC}"
curl -s http://localhost:8000 || echo -e "${RED}No se pudo acceder al servicio User${NC}"

echo -e "${YELLOW}4.2: Servicio Companies:${NC}"
curl -s http://localhost:8010/health || echo -e "${RED}No se pudo acceder al servicio Companies${NC}"

echo -e "${YELLOW}4.3: API Gateway - User:${NC}"
curl -s http://localhost:81/v1/ || echo -e "${RED}No se pudo acceder al API Gateway - User${NC}"

echo -e "${YELLOW}4.4: API Gateway - Companies:${NC}"
curl -s http://localhost:81/v1/companies || echo -e "${RED}No se pudo acceder al API Gateway - Companies${NC}"

echo -e "${YELLOW}4.5: Frontend:${NC}"
curl -s -I http://localhost:8080 | head -n 1 || echo -e "${RED}No se pudo acceder al Frontend${NC}"

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Plataforma Rantipay SaaS híbrida expandida lista para usar   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81${NC}"
echo -e "${GREEN}Servicios disponibles:${NC}"
echo -e "${GREEN}  - User: http://localhost:8000${NC}"
echo -e "${GREEN}  - Companies: http://localhost:8010${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f docker-compose-hybrid-plus.yml down${NC}"
echo ""
echo -e "${YELLOW}A continuación, puedes continuar integrando otros servicios personalizados.${NC}"
