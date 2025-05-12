#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Verificando estado del servicio user   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Verificar si los contenedores están en ejecución
echo -e "${YELLOW}Paso 1: Verificando si los contenedores están en ejecución...${NC}"
CONTAINERS=$(docker ps --format "{{.Names}}" | grep -E "user|nginx|web|mysql|redis|etcd")
if [ -n "$CONTAINERS" ]; then
    echo -e "${GREEN}✓ Contenedores en ejecución:${NC}"
    docker ps | grep -E "user|nginx|web|mysql|redis|etcd"
else
    echo -e "${RED}× No se encontraron contenedores en ejecución${NC}"
    echo -e "${YELLOW}Iniciando los servicios...${NC}"
    docker compose -f docker-compose-corrected-user.yml up -d
    sleep 5
    docker ps | grep -E "user|nginx|web|mysql|redis|etcd"
fi
echo ""

# Paso 2: Verificar logs del servicio user
echo -e "${YELLOW}Paso 2: Verificando logs del servicio user...${NC}"
USER_CONTAINER=$(docker ps --format "{{.Names}}" | grep -E "user" | head -1)
if [ -n "$USER_CONTAINER" ]; then
    echo -e "${GREEN}✓ Contenedor de user encontrado: $USER_CONTAINER${NC}"
    echo -e "${YELLOW}Últimas 20 líneas de logs:${NC}"
    docker logs $USER_CONTAINER | tail -20
    
    # Verificar si hay errores comunes
    if docker logs $USER_CONTAINER | grep -i "error" | grep -v "level=error"; then
        echo -e "${RED}× Se encontraron errores en los logs${NC}"
        echo -e "${YELLOW}Errores encontrados:${NC}"
        docker logs $USER_CONTAINER | grep -i "error" | grep -v "level=error" | head -10
    else
        echo -e "${GREEN}✓ No se encontraron errores graves en los logs${NC}"
    fi
else
    echo -e "${RED}× No se encontró el contenedor de user${NC}"
fi
echo ""

# Paso 3: Verificar si el servicio está respondiendo
echo -e "${YELLOW}Paso 3: Verificando si el servicio está respondiendo...${NC}"
# Intentar varias rutas
ROUTES=("/health" "/v1/user/me" "/v1/sys/menus/available")
for ROUTE in "${ROUTES[@]}"; do
    echo -e "${YELLOW}Probando ruta: $ROUTE${NC}"
    RESPONSE=$(curl -s http://localhost:8000$ROUTE)
    if [ -n "$RESPONSE" ]; then
        echo -e "${GREEN}✓ Respuesta recibida:${NC}"
        echo "$RESPONSE" | head -5
    else
        echo -e "${RED}× No se recibió respuesta${NC}"
    fi
    echo ""
done

# Paso 4: Verificar el API Gateway
echo -e "${YELLOW}Paso 4: Verificando el API Gateway...${NC}"
NGINX_CONTAINER=$(docker ps --format "{{.Names}}" | grep -E "nginx" | head -1)
if [ -n "$NGINX_CONTAINER" ]; then
    echo -e "${GREEN}✓ Contenedor de NGINX encontrado: $NGINX_CONTAINER${NC}"
    echo -e "${YELLOW}Últimas 10 líneas de logs:${NC}"
    docker logs $NGINX_CONTAINER | tail -10
    
    # Probar el API Gateway
    echo -e "${YELLOW}Probando el API Gateway...${NC}"
    RESPONSE=$(curl -s http://localhost:81/health)
    if [ -n "$RESPONSE" ]; then
        echo -e "${GREEN}✓ API Gateway respondiendo:${NC}"
        echo "$RESPONSE"
    else
        echo -e "${RED}× API Gateway no responde${NC}"
    fi
else
    echo -e "${RED}× No se encontró el contenedor de NGINX${NC}"
fi
echo ""

# Paso 5: Verificar la conectividad entre contenedores
echo -e "${YELLOW}Paso 5: Verificando la conectividad entre contenedores...${NC}"
if [ -n "$USER_CONTAINER" ]; then
    echo -e "${YELLOW}Verificando conexión a MySQL...${NC}"
    docker exec $USER_CONTAINER wget -q -O- mysqld:3306 > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Conexión a MySQL exitosa${NC}"
    else
        echo -e "${RED}× Error al conectar con MySQL${NC}"
    fi
    
    echo -e "${YELLOW}Verificando conexión a Redis...${NC}"
    docker exec $USER_CONTAINER wget -q -O- redis:6379 > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Conexión a Redis exitosa${NC}"
    else
        echo -e "${RED}× Error al conectar con Redis${NC}"
    fi
    
    echo -e "${YELLOW}Verificando conexión a ETCD...${NC}"
    docker exec $USER_CONTAINER wget -q -O- etcd:2379 > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Conexión a ETCD exitosa${NC}"
    else
        echo -e "${RED}× Error al conectar con ETCD${NC}"
    fi
fi
echo ""

# Paso 6: Verificar el frontend
echo -e "${YELLOW}Paso 6: Verificando el frontend...${NC}"
WEB_CONTAINER=$(docker ps --format "{{.Names}}" | grep -E "web" | head -1)
if [ -n "$WEB_CONTAINER" ]; then
    echo -e "${GREEN}✓ Contenedor de frontend encontrado: $WEB_CONTAINER${NC}"
    echo -e "${YELLOW}Últimas 10 líneas de logs:${NC}"
    docker logs $WEB_CONTAINER | tail -10
    
    echo -e "${YELLOW}Abre http://localhost:8080 en tu navegador para verificar el frontend${NC}"
else
    echo -e "${RED}× No se encontró el contenedor de frontend${NC}"
fi
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Recomendaciones basadas en el análisis   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""

if [ -n "$USER_CONTAINER" ] && ! docker logs $USER_CONTAINER | grep -i "error" | grep -v "level=error"; then
    echo -e "${GREEN}✓ El servicio user parece estar funcionando correctamente${NC}"
    echo -e "${YELLOW}Para acceder a la aplicación, abre http://localhost:8080 en tu navegador${NC}"
    echo -e "${YELLOW}Credenciales de inicio de sesión:${NC}"
    echo -e "   - Usuario: ${GREEN}admin@rantipay.com${NC}"
    echo -e "   - Contraseña: ${GREEN}Admin123!${NC}"
else
    echo -e "${RED}× El servicio user está teniendo problemas${NC}"
    echo -e "${YELLOW}Opciones para solucionar:${NC}"
    echo -e "1. Revisa los logs completos: ${YELLOW}docker logs $USER_CONTAINER${NC}"
    echo -e "2. Verifica que la configuración sea correcta: ${YELLOW}cat configs/user/config.yaml${NC}"
    echo -e "3. Asegúrate de que MySQL, Redis y ETCD estén funcionando correctamente"
    echo -e "4. Si los problemas persisten, considera usar el servicio simple-user:"
    echo -e "   ${YELLOW}./fix-404-errors.sh${NC}"
fi
echo ""
