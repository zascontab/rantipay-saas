#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Archivo de configuración
DOCKER_COMPOSE_FILE="docker-compose-simple-fixed.yml"

# Verificar que el archivo de Docker Compose exista
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${RED}Error: Archivo $DOCKER_COMPOSE_FILE no encontrado.${NC}"
    exit 1
fi

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS con simple-user   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Verificar la configuración NGINX
echo -e "${YELLOW}Verificando configuración de NGINX...${NC}"
if [ ! -f "nginx-gateway/nginx-simple-proxy.conf" ]; then
    echo -e "${RED}El archivo nginx-gateway/nginx-simple-proxy.conf no existe.${NC}"
    echo -e "${YELLOW}Creando archivo...${NC}"
    mkdir -p nginx-gateway
    
    cat > nginx-gateway/nginx-simple-proxy.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    sendfile        on;
    keepalive_timeout  65;

    # Configuración para logs y manejo de errores
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log  /var/log/nginx/access.log  main;
    error_log   /var/log/nginx/error.log  warn;

    # Buffers aumentados para mejorar rendimiento
    proxy_buffer_size   128k;
    proxy_buffers       4 256k;
    proxy_busy_buffers_size 256k;

    # Timeouts aumentados
    proxy_connect_timeout 60s;
    proxy_read_timeout 60s;
    proxy_send_timeout 60s;

    server {
        listen 80;
        server_name localhost;
        
        # Ruta para el servicio user simple
        location /v1/ {
            proxy_pass http://user:8000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Ruta directa para el servicio user
        location = /v1 {
            proxy_pass http://user:8000/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Ruta para health check
        location /health {
            access_log off;
            return 200 "API Gateway Healthy\n";
        }
        
        # Ruta de fallback
        location / {
            return 404 'API Gateway: Endpoint not found';
        }
    }
}
EOF
    
    echo -e "${GREEN}Archivo nginx-gateway/nginx-simple-proxy.conf creado.${NC}"
fi

# Copiar a nginx.conf para asegurar consistencia
cp nginx-gateway/nginx-simple-proxy.conf nginx-gateway/nginx.conf
echo -e "${GREEN}✓ Configuración de NGINX verificada${NC}"
echo ""

# Paso 1: Detener cualquier instancia previa
echo -e "${YELLOW}Paso 1: Deteniendo instancias previas...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE down 2>/dev/null || true
echo -e "${GREEN}✓ Instancias previas detenidas${NC}"
echo ""

# Paso 2: Limpiar volúmenes antiguos
echo -e "${YELLOW}Paso 2: Limpiando volúmenes antiguos...${NC}"
docker volume rm rantipay_saas_etcd_data 2>/dev/null || true
docker volume rm rantipay_saas_mysql_data 2>/dev/null || true
echo -e "${GREEN}✓ Volúmenes antiguos limpiados${NC}"
echo ""

# Verificar si la imagen simple-user:debug existe
echo -e "${YELLOW}Verificando imagen simple-user:debug...${NC}"
if ! docker images | grep -q "simple-user" | grep -q "debug"; then
    echo -e "${YELLOW}Construyendo imagen simple-user:debug...${NC}"
    if [ ! -d "simple-user" ]; then
        echo -e "${RED}Error: Directorio simple-user no encontrado.${NC}"
        exit 1
    fi
    cd simple-user
    docker build -t simple-user:debug -f Dockerfile.debug .
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error al construir la imagen simple-user:debug${NC}"
        cd ..
        exit 1
    fi
    cd ..
fi
echo -e "${GREEN}✓ Imagen simple-user:debug disponible${NC}"
echo ""

# Verificar configuración del frontend
echo -e "${YELLOW}Verificando configuración del frontend...${NC}"
if [ ! -d "kit-frontend/docker/nginx" ]; then
    echo -e "${YELLOW}Creando directorio para configuración del frontend...${NC}"
    mkdir -p kit-frontend/docker/nginx
fi

if [ ! -f "kit-frontend/docker/nginx/default.conf" ]; then
    echo -e "${YELLOW}Creando archivo de configuración del frontend...${NC}"
    cat > kit-frontend/docker/nginx/default.conf << 'EOF'
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files $uri $uri/ /index.html;
    }

    # Redirigir todas las llamadas a la API a NGINX Gateway
    location /v1/ {
        proxy_pass http://nginx:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_connect_timeout 300;
        proxy_send_timeout 300;
        proxy_read_timeout 300;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
    echo -e "${GREEN}Archivo de configuración del frontend creado.${NC}"
fi
echo -e "${GREEN}✓ Configuración del frontend verificada${NC}"
echo ""

# Paso 3: Inicio de servicios de infraestructura
echo -e "${YELLOW}Paso 3: Iniciando servicios de infraestructura...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d mysqld redis etcd
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar servicios de infraestructura${NC}"
    echo -e "${YELLOW}Mostrando el contenido del archivo $DOCKER_COMPOSE_FILE:${NC}"
    head -n 20 $DOCKER_COMPOSE_FILE
    echo -e "${YELLOW}[...]${NC}"
    echo -e "${YELLOW}Verificando si docker compose está instalado:${NC}"
    docker compose version
    exit 1
fi
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 4: Esperar a que los servicios estén disponibles
echo -e "${YELLOW}Paso 4: Esperando a que los servicios de infraestructura estén disponibles...${NC}"
for i in {1..20}; do
    MYSQLD_CONTAINER=$(docker ps -q -f name=rantipay_saas-mysqld)
    if [ -z "$MYSQLD_CONTAINER" ]; then
        echo -e "${RED}Contenedor MySQL no encontrado${NC}"
        echo -e "${YELLOW}Verificando contenedores en ejecución:${NC}"
        docker ps
        exit 1
    fi
    
    if docker exec $MYSQLD_CONTAINER mysqladmin -u root -pyouShouldChangeThis ping 2>/dev/null; then
        echo -e "${GREEN}✓ MySQL está listo${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${RED}× Tiempo de espera agotado para MySQL${NC}"
        docker logs $MYSQLD_CONTAINER
        exit 1
    fi
    echo -n "."
    sleep 2
done

REDIS_CONTAINER=$(docker ps -q -f name=rantipay_saas-redis)
for i in {1..20}; do
    if [ -z "$REDIS_CONTAINER" ]; then
        echo -e "${RED}Contenedor Redis no encontrado${NC}"
        exit 1
    fi
    
    if docker exec $REDIS_CONTAINER redis-cli -a youShouldChangeThis ping 2>/dev/null | grep -q "PONG"; then
        echo -e "${GREEN}✓ Redis está listo${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${RED}× Tiempo de espera agotado para Redis${NC}"
        docker logs $REDIS_CONTAINER
        exit 1
    fi
    echo -n "."
    sleep 2
done

ETCD_CONTAINER=$(docker ps -q -f name=rantipay_saas-etcd)
for i in {1..20}; do
    if [ -z "$ETCD_CONTAINER" ]; then
        echo -e "${RED}Contenedor ETCD no encontrado${NC}"
        exit 1
    fi
    
    if docker exec $ETCD_CONTAINER etcdctl endpoint health 2>/dev/null; then
        echo -e "${GREEN}✓ ETCD está listo${NC}"
        break
    fi
    if [ $i -eq 20 ]; then
        echo -e "${RED}× Tiempo de espera agotado para ETCD${NC}"
        docker logs $ETCD_CONTAINER
        exit 1
    fi
    echo -n "."
    sleep 2
done
echo ""

# Paso 5: Inicializar la base de datos
echo -e "${YELLOW}Paso 5: Inicializando base de datos...${NC}"
./init-database.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al inicializar la base de datos${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Base de datos inicializada${NC}"
echo ""

# Paso 6: Registrar servicios en ETCD
echo -e "${YELLOW}Paso 6: Inicializando ETCD...${NC}"
./init-etcd.sh
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al inicializar ETCD${NC}"
    exit 1
fi
echo -e "${GREEN}✓ ETCD inicializado${NC}"
echo ""

# Paso 7: Iniciar servicio user
echo -e "${YELLOW}Paso 7: Iniciando servicio user simplificado...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d user
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar el servicio user${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicio user iniciado${NC}"
echo ""

# Esperar a que el servicio user esté listo
echo -e "${YELLOW}Esperando a que el servicio user esté disponible...${NC}"
USER_CONTAINER=$(docker ps -q -f name=rantipay_saas-user)
for i in {1..15}; do
    if docker exec $USER_CONTAINER curl -s localhost:8000 2>/dev/null | grep -q "Hello"; then
        echo -e "${GREEN}✓ User service está listo${NC}"
        break
    fi
    if [ $i -eq 15 ]; then
        echo -e "${RED}× Tiempo de espera agotado para User service${NC}"
        docker logs $USER_CONTAINER
    fi
    echo -n "."
    sleep 2
done
echo ""

# Paso 8: Iniciar API Gateway y Frontend
echo -e "${YELLOW}Paso 8: Iniciando API Gateway y Frontend...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d nginx web
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al iniciar API Gateway y Frontend${NC}"
    exit 1
fi
echo -e "${GREEN}✓ API Gateway y Frontend iniciados${NC}"
echo ""

# Paso 9: Verificar todos los servicios
echo -e "${YELLOW}Paso 9: Verificando estado de los servicios...${NC}"
sleep 5  # Dar tiempo a que los servicios se inicien completamente

# Verificar servicio user
echo -e "${YELLOW}Verificando servicio user:${NC}"
USER_RESPONSE=$(docker exec $USER_CONTAINER curl -s localhost:8000 2>/dev/null)
if echo "$USER_RESPONSE" | grep -q "Hello"; then
    echo -e "${GREEN}  ✓ User Service (simple) está funcionando correctamente${NC}"
    echo -e "${GREEN}    Respuesta: $(echo "$USER_RESPONSE" | head -n 1)${NC}"
else
    echo -e "${RED}  ✗ User Service no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Mostrando logs del servicio user:${NC}"
    docker logs $USER_CONTAINER 2>/dev/null || echo "No se pudieron obtener logs"
fi

# Verificar API Gateway
NGINX_CONTAINER=$(docker ps -q -f name=rantipay_saas-nginx)
echo -e "${YELLOW}Verificando API Gateway:${NC}"
NGINX_RESPONSE=$(docker exec $NGINX_CONTAINER curl -s localhost/health 2>/dev/null)
if echo "$NGINX_RESPONSE" | grep -q "Gateway" || echo "$NGINX_RESPONSE" | grep -q "Healthy"; then
    echo -e "${GREEN}  ✓ API Gateway está funcionando correctamente${NC}"
    echo -e "${GREEN}    Respuesta: $(echo "$NGINX_RESPONSE" | head -n 1)${NC}"
else
    echo -e "${RED}  ✗ API Gateway no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Mostrando logs del API Gateway:${NC}"
    docker logs $NGINX_CONTAINER 2>/dev/null || echo "No se pudieron obtener logs"
fi

# Verificar API Gateway - Proxy al servicio user
echo -e "${YELLOW}Verificando API Gateway - Proxy al servicio user:${NC}"
NGINX_USER_RESPONSE=$(docker exec $NGINX_CONTAINER curl -s localhost/v1 2>/dev/null)
if echo "$NGINX_USER_RESPONSE" | grep -q "Hello"; then
    echo -e "${GREEN}  ✓ API Gateway está correctamente redirigiendo al servicio user${NC}"
    echo -e "${GREEN}    Respuesta: $(echo "$NGINX_USER_RESPONSE" | head -n 1)${NC}"
else
    echo -e "${RED}  ✗ API Gateway no está redirigiendo correctamente al servicio user${NC}"
    echo -e "${YELLOW}  Mostrando logs del API Gateway:${NC}"
    docker logs $NGINX_CONTAINER 2>/dev/null || echo "No se pudieron obtener logs"
    
    echo -e "${YELLOW}  Mostrando configuración de NGINX:${NC}"
    docker exec $NGINX_CONTAINER cat /etc/nginx/nginx.conf | head -n 20
    echo -e "${YELLOW}  [...]${NC}"
fi

# Verificar Frontend
WEB_CONTAINER=$(docker ps -q -f name=rantipay_saas-web)
echo -e "${YELLOW}Verificando Frontend:${NC}"
if [ -n "$WEB_CONTAINER" ]; then
    WEB_RESPONSE=$(docker exec $WEB_CONTAINER curl -s -I localhost 2>/dev/null)
    if echo "$WEB_RESPONSE" | grep -q "200 OK"; then
        echo -e "${GREEN}  ✓ Frontend está funcionando correctamente${NC}"
    else
        echo -e "${RED}  ✗ Frontend no está funcionando correctamente${NC}"
        echo -e "${YELLOW}  Mostrando logs del Frontend:${NC}"
        docker logs $WEB_CONTAINER 2>/dev/null || echo "No se pudieron obtener logs"
    fi
else
    echo -e "${RED}  ✗ Contenedor del Frontend no está en ejecución${NC}"
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Plataforma Rantipay SaaS lista para usar   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81/v1/${NC}"
echo -e "${GREEN}Servicio User simplificado disponible en: http://localhost:8000${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f $DOCKER_COMPOSE_FILE down${NC}"
echo ""
echo -e "${YELLOW}Para ver logs de un servicio específico:${NC}"
echo -e "${YELLOW}docker logs -f rantipay_saas-[nombre_servicio]-1${NC}"
echo -e "${YELLOW}Ejemplo: docker logs -f rantipay_saas-user-1${NC}"