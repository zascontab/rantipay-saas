#!/bin/bash
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Registrando servicio Companies en APISIX...${NC}"

# Añadir ruta para Companies
curl -i http://localhost:9180/apisix/admin/routes/companies -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '
{
  "uri": "/v1/companies/*",
  "host": "*",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "localhost:8010": 1
    }
  }
}'

echo -e "${GREEN}✓ Servicio Companies registrado en APISIX${NC}"
echo -e "${GREEN}Ahora puedes acceder al servicio desde:${NC}"
echo -e "${GREEN}http://localhost:9080/v1/companies/${NC}"