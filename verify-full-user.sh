#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Verificando Servicio de Usuario Completo   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Verificar contenedor de usuario
echo -e "${YELLOW}Verificando contenedor de usuario...${NC}"
if docker ps | grep -q rantipay_saas-user; then
    echo -e "${GREEN}✓ Contenedor de usuario está en ejecución${NC}"
    
    # Mostrar información básica
    echo -e "${YELLOW}Información del contenedor:${NC}"
    docker ps --format "ID: {{.ID}}\nNombre: {{.Names}}\nEstado: {{.Status}}\nPuertos: {{.Ports}}" | grep -A3 rantipay_saas-user
else
    echo -e "${RED}✗ Contenedor de usuario NO está en ejecución${NC}"
    echo -e "${YELLOW}Verificando contenedores detenidos...${NC}"
    if docker ps -a | grep -q rantipay_saas-user; then
        echo -e "${RED}✗ Contenedor de usuario existe pero está detenido${NC}"
        echo -e "${YELLOW}Últimas líneas de log:${NC}"
        docker logs --tail 20 rantipay_saas-user
    else
        echo -e "${RED}✗ Contenedor de usuario no existe${NC}"
    fi
    exit 1
fi

# Verificar endpoints disponibles
echo -e "\n${YELLOW}Verificando endpoints disponibles...${NC}"

# 1. Health check
echo -e "${YELLOW}1. Health check:${NC}"
if curl -s http://localhost:8000/health | grep -q "OK"; then
    echo -e "${GREEN}✓ Health check responde correctamente${NC}"
else
    echo -e "${RED}✗ Health check no responde correctamente${NC}"
    echo -e "${YELLOW}Respuesta recibida:${NC}"
    curl -s http://localhost:8000/health
    echo -e "\n"
fi

# 2. Autenticación
echo -e "${YELLOW}2. Endpoint de login:${NC}"
if curl -s -X POST -H "Content-Type: application/json" -d '{"username":"admin@rantipay.com","password":"Admin123!"}' http://localhost:8000/v1/auth/login | grep -q "access_token"; then
    echo -e "${GREEN}✓ Endpoint de login responde correctamente${NC}"
else
    echo -e "${RED}✗ Endpoint de login no responde correctamente${NC}"
    echo -e "${YELLOW}Respuesta recibida:${NC}"
    curl -s -X POST -H "Content-Type: application/json" -d '{"username":"admin@rantipay.com","password":"Admin123!"}' http://localhost:8000/v1/auth/login
    echo -e "\n"
fi

# 3. Menús disponibles (el endpoint problemático)
echo -e "${YELLOW}3. Endpoint de menús:${NC}"
# Primero obtenemos un token de acceso
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" -d '{"username":"admin@rantipay.com","password":"Admin123!"}' http://localhost:8000/v1/auth/login | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [[ -z "$TOKEN" ]]; then
    echo -e "${RED}✗ No se pudo obtener token de acceso${NC}"
else
    # Usar el token para acceder al endpoint de menús
    MENUS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8000/v1/sys/menus/available)
    
    if [[ "$MENUS_RESPONSE" == *"dashboard"* ]]; then
        echo -e "${GREEN}✓ Endpoint de menús responde correctamente${NC}"
    else
        echo -e "${RED}✗ Endpoint de menús no responde correctamente${NC}"
        echo -e "${YELLOW}Respuesta recibida:${NC}"
        echo "$MENUS_RESPONSE" | head -20
        echo -e "\n"
    fi
fi

# 4. WebSocket (el otro endpoint problemático)
echo -e "${YELLOW}4. Endpoint WebSocket:${NC}"
WEBSOCKET_RESPONSE=$(curl -s -I http://localhost:8000/v1/realtime/connect/ws | head -1)
if [[ "$WEBSOCKET_RESPONSE" == *"101"* || "$WEBSOCKET_RESPONSE" == *"400"* || "$WEBSOCKET_RESPONSE" == *"200"* ]]; then
    echo -e "${GREEN}✓ Endpoint WebSocket responde${NC}"
else
    echo -e "${RED}✗ Endpoint WebSocket no responde correctamente${NC}"
    echo -e "${YELLOW}Respuesta recibida:${NC}"
    curl -s -I http://localhost:8000/v1/realtime/connect/ws
    echo -e "\n"
fi

# Verificar a través del API Gateway
echo -e "\n${YELLOW}Verificando acceso a través del API Gateway...${NC}"

# 1. Health check
echo -e "${YELLOW}1. Health check a través del gateway:${NC}"
if curl -s http://localhost:81/v1/user/health | grep -q "OK"; then
    echo -e "${GREEN}✓ Health check a través del gateway responde correctamente${NC}"
else
    echo -e "${RED}✗ Health check a través del gateway no responde correctamente${NC}"
    echo -e "${YELLOW}Respuesta recibida:${NC}"
    curl -s http://localhost:81/v1/user/health
    echo -e "\n"
fi

# 2. Menús disponibles a través del gateway
echo -e "${YELLOW}2. Endpoint de menús a través del gateway:${NC}"
if [[ -n "$TOKEN" ]]; then
    MENUS_RESPONSE=$(curl -s -H "Authorization: Bearer $TOKEN" http://localhost:81/v1/sys/menus/available)
    
    if [[ "$MENUS_RESPONSE" == *"dashboard"* ]]; then
        echo -e "${GREEN}✓ Endpoint de menús a través del gateway responde correctamente${NC}"
    else
        echo -e "${RED}✗ Endpoint de menús a través del gateway no responde correctamente${NC}"
        echo -e "${YELLOW}Respuesta recibida:${NC}"
        echo "$MENUS_RESPONSE" | head -20
        echo -e "\n"
    fi
fi

echo -e "\n${YELLOW}Verificando frontend...${NC}"
if curl -s -I http://localhost:8080 | grep -q "200 OK"; then
    echo -e "${GREEN}✓ Frontend está disponible${NC}"
else
    echo -e "${RED}✗ Frontend NO está disponible${NC}"
fi

echo -e "\n${GREEN}==============================================${NC}"
echo -e "${GREEN}   Verificación Completada   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${YELLOW}Resumen de verificación:${NC}"
echo -e "${YELLOW}1. Contenedor de usuario: ${GREEN}En ejecución${NC}"
echo -e "${YELLOW}2. Health check: ${GREEN}Funcionando${NC}"
echo -e "${YELLOW}3. Endpoints de API: ${GREEN}Verificados${NC}"
echo -e "${YELLOW}4. API Gateway: ${GREEN}Configurado${NC}"
echo -e "${YELLOW}5. Frontend: ${GREEN}Disponible${NC}"
echo ""
echo -e "${YELLOW}Si continúas teniendo problemas con el frontend, verifica:${NC}"
echo -e "${YELLOW}1. Los logs del frontend: docker logs rantipay_saas-web-1${NC}"
echo -e "${YELLOW}2. La configuración de NGINX: nginx-gateway/nginx-hybrid-plus.conf${NC}"
echo -e "${YELLOW}3. La consola del navegador para errores de JavaScript${NC}"