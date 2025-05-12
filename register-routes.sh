#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Registrando rutas en APISIX   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Obtener la IP del host
HOST_IP=$(hostname -I | awk '{print $1}')
echo -e "IP del host: ${GREEN}$HOST_IP${NC}"

# Registrar el servicio User
echo -e "${YELLOW}Registrando servicio User...${NC}"
curl -i http://localhost:9180/apisix/admin/routes/user -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '{
  "uri": "/v1/user/*",
  "host": "*",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "'$HOST_IP':8000": 1
    }
  }
}'

echo -e "\n${YELLOW}Registrando servicio SaaS...${NC}"
curl -i http://localhost:9180/apisix/admin/routes/saas -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '{
  "uri": "/v1/saas/*",
  "host": "*",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "'$HOST_IP':8001": 1
    }
  }
}'

echo -e "\n${YELLOW}Registrando servicio Sys...${NC}"
curl -i http://localhost:9180/apisix/admin/routes/sys -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '{
  "uri": "/v1/sys/*",
  "host": "*",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "'$HOST_IP':8002": 1
    }
  }
}'

echo -e "\n${YELLOW}Registrando servicio Companies...${NC}"
curl -i http://localhost:9180/apisix/admin/routes/companies -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '{
  "uri": "/v1/companies/*",
  "host": "*",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "'$HOST_IP':8010": 1
    }
  }
}'

echo -e "\n${GREEN}Rutas registradas correctamente${NC}"
echo -e "${YELLOW}Verificando acceso a través de APISIX...${NC}"
curl -i http://localhost:9080/v1/sys/menus/available

echo -e "\n${GREEN}==============================================${NC}"
echo -e "${GREEN}   Frontend disponible en: http://localhost:8090   ${NC}"
echo -e "${GREEN}==============================================${NC}"
