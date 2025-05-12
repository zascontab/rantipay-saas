#!/bin/bash

# Colors for messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Configurando APISIX con la instalación de kit existente   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Verificar si APISIX está corriendo en kit
APISIX_CONTAINER=$(docker ps | grep kit_apisix | awk '{print $1}')
if [ -z "$APISIX_CONTAINER" ]; then
    echo -e "${YELLOW}APISIX no está corriendo en kit, vamos a iniciarlo${NC}"
    
    # Navegar al directorio de kit
    cd kit
    
    # Iniciar solo APISIX
    docker compose up -d apisix apisix-dashboard
    
    # Volver al directorio original
    cd ..
    
    # Esperar a que APISIX esté listo
    echo -e "${YELLOW}Esperando a que APISIX esté listo...${NC}"
    sleep 10
    
    # Verificar si APISIX se inició correctamente
    APISIX_CONTAINER=$(docker ps | grep kit_apisix | awk '{print $1}')
    if [ -z "$APISIX_CONTAINER" ]; then
        echo -e "${RED}Error: No se pudo iniciar APISIX${NC}"
        exit 1
    fi
fi

# Obtener la IP y el puerto de APISIX
APISIX_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $APISIX_CONTAINER)
APISIX_PORT=$(docker port $APISIX_CONTAINER 9080 | cut -d ':' -f 2)
APISIX_ADMIN_PORT=$(docker port $APISIX_CONTAINER 9180 | cut -d ':' -f 2)

if [ -z "$APISIX_PORT" ]; then
    APISIX_PORT="9080"
fi

if [ -z "$APISIX_ADMIN_PORT" ]; then
    APISIX_ADMIN_PORT="9180"
fi

echo -e "${GREEN}APISIX IP: $APISIX_IP${NC}"
echo -e "${GREEN}APISIX Puerto: $APISIX_PORT${NC}"
echo -e "${GREEN}APISIX Admin Puerto: $APISIX_ADMIN_PORT${NC}"

# Registrar el servicio Companies en APISIX
echo -e "${YELLOW}Registrando servicio Companies en APISIX...${NC}"

# Obtener la IP del host
HOST_IP=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}IP del host: $HOST_IP${NC}"

curl -i http://localhost:$APISIX_ADMIN_PORT/apisix/admin/routes/companies -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '{
  "uri": "/v1/companies/*",
  "host": "*",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "'$HOST_IP':8010": 1
    }
  }
}'

echo -e "${GREEN}✓ Servicio Companies registrado en APISIX${NC}"
echo ""
echo -e "${GREEN}Puedes acceder al servicio Companies a través de APISIX:${NC}"
echo -e "${GREEN}http://localhost:$APISIX_PORT/v1/companies/${NC}"
