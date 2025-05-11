#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Prueba de Login para Rantipay SaaS   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Reconstruir servicio de usuario
echo -e "${YELLOW}Paso 1: Reconstruyendo servicio de usuario...${NC}"
docker compose -f docker-compose-hybrid-plus.yml build simple-user
docker compose -f docker-compose-hybrid-plus.yml restart simple-user nginx
sleep 3
echo -e "${GREEN}✓ Servicio reconstruido y reiniciado${NC}"
echo ""

# Paso 2: Probar login directamente al servicio
echo -e "${YELLOW}Paso 2: Probando login directamente al servicio de usuario...${NC}"
echo -e "${YELLOW}Credenciales: admin@rantipay.com / Admin123!${NC}"
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"username":"admin@rantipay.com","password":"Admin123!"}' http://localhost:8000/v1/auth/login)
echo -e "${GREEN}Respuesta:${NC}"
echo $RESPONSE | jq . || echo $RESPONSE
echo ""

# Paso 3: Extraer token
TOKEN=$(echo $RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
if [[ -n "$TOKEN" ]]; then
    echo -e "${GREEN}✓ Token obtenido: $TOKEN${NC}"
else
    echo -e "${RED}✗ No se pudo obtener token${NC}"
fi
echo ""

# Paso 4: Probar login a través de NGINX
echo -e "${YELLOW}Paso 4: Probando login a través de NGINX...${NC}"
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d '{"username":"admin@rantipay.com","password":"Admin123!"}' http://localhost:81/v1/auth/login)
echo -e "${GREEN}Respuesta:${NC}"
echo $RESPONSE | jq . || echo $RESPONSE
echo ""

# Paso 5: Extraer token
TOKEN=$(echo $RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
if [[ -n "$TOKEN" ]]; then
    echo -e "${GREEN}✓ Token obtenido: $TOKEN${NC}"
else
    echo -e "${RED}✗ No se pudo obtener token${NC}"
fi
echo ""

# Paso 6: Verificar endpoint de menús
echo -e "${YELLOW}Paso 6: Verificando endpoint de menús con el token...${NC}"
if [[ -n "$TOKEN" ]]; then
    RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:81/v1/sys/menus/available | head -c 100)
    echo -e "${GREEN}Respuesta (primeros 100 caracteres):${NC}"
    echo $RESPONSE
else
    echo -e "${RED}✗ No se pudo verificar el endpoint de menús (no hay token)${NC}"
fi
echo ""

# Paso 7: Verificación del frontend
echo -e "${YELLOW}Paso 7: Para verificar el frontend, sigue estos pasos:${NC}"
echo -e "1. Abre ${GREEN}http://localhost:8080${NC} en tu navegador"
echo -e "2. Usa estas credenciales:"
echo -e "   - Usuario: ${GREEN}admin@rantipay.com${NC}"
echo -e "   - Contraseña: ${GREEN}Admin123!${NC}"
echo -e "3. Si los problemas persisten:"
echo -e "   - Verifica la consola del navegador para errores"
echo -e "   - Comprueba los logs del frontend: ${YELLOW}docker logs rantipay_saas-web-1${NC}"
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Prueba de Login Completada   ${NC}"
echo -e "${GREEN}==============================================${NC}"
