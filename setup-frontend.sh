#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Configurando frontend temporal...${NC}"

# Actualizar docker-compose.yml para añadir el frontend
cat >> docker-compose.yml << 'EOFDC'

  # Frontend temporal
  web:
    image: goxiaoy/go-saas-kit-frontend:dev
    ports:
      - "8080:80"
    networks:
      - rantipay-network
EOFDC

# Iniciar el frontend
docker compose up -d web

echo -e "${GREEN}✓ Frontend iniciado correctamente${NC}"
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"