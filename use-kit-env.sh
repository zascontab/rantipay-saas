#!/bin/bash

# Colors for messages
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Usando el entorno kit existente   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Verificar si el servicio Companies está corriendo
if ! ps aux | grep -q "[b]in/companies"; then
    echo -e "${YELLOW}El servicio Companies no está corriendo, vamos a iniciarlo${NC}"
    
    # Navegar al directorio companies-service
    cd companies-service
    
    # Compilar si es necesario
    if [ ! -f "./bin/companies" ]; then
        echo -e "${YELLOW}Compilando servicio Companies...${NC}"
        go build -o bin/companies ./cmd/server
    fi
    
    # Iniciar el servicio
    echo -e "${YELLOW}Iniciando servicio Companies...${NC}"
    ./bin/companies &
    COMPANIES_PID=$!
    echo $COMPANIES_PID > ../.companies.pid
    
    cd ..
    
    echo -e "${GREEN}✓ Servicio Companies iniciado con PID $COMPANIES_PID${NC}"
else
    echo -e "${GREEN}El servicio Companies ya está corriendo${NC}"
fi

# Encontrar el puerto de APISIX
echo -e "${YELLOW}Buscando puerto de APISIX...${NC}"
APISIX_CONTAINER=$(docker ps | grep "kit-apisix-" | head -1 | awk '{print $1}')
if [ -n "$APISIX_CONTAINER" ]; then
    echo -e "${GREEN}Contenedor APISIX encontrado: $APISIX_CONTAINER${NC}"
    
    # Obtener puertos
    echo -e "${YELLOW}Obteniendo puertos...${NC}"
    docker port $APISIX_CONTAINER | grep -E "9080|9180"
    
    # Registrar servicio Companies en APISIX
    echo -e "${YELLOW}Registrando servicio Companies en APISIX...${NC}"
    
    # Obtener IP del host
    HOST_IP=$(hostname -I | awk '{print $1}')
    echo -e "${GREEN}IP del host: $HOST_IP${NC}"
    
    # Configurar la ruta en APISIX
    curl -i http://localhost:9080/apisix/admin/routes/companies -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d '{
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
else
    echo -e "${RED}No se encontró un contenedor APISIX funcionando${NC}"
    echo -e "${YELLOW}Utilizando el kit original para ver los contenedores...${NC}"
    cd kit
    docker compose ps
    cd ..
fi

# Verificar si podemos acceder al servicio Companies directamente
echo -e "${YELLOW}Verificando servicio Companies...${NC}"
curl -i http://localhost:8010/health

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Entorno configurado correctamente   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
