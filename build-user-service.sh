#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Construcción del Servicio User Completo   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Comprobar que estamos en el directorio correcto
if [ ! -d "kit/user" ]; then
    echo -e "${RED}Error: No se encuentra el directorio kit/user${NC}"
    echo -e "${YELLOW}Asegúrate de estar en el directorio raíz del proyecto${NC}"
    exit 1
fi

# Crear directorios para la configuración si no existen
echo -e "${YELLOW}Creando directorios de configuración...${NC}"
mkdir -p configs/user
echo -e "${GREEN}✓ Directorios creados${NC}"
echo ""

# Crear archivo de configuración para el servicio user
echo -e "${YELLOW}Creando archivo de configuración...${NC}"
cat > configs/user/config.yaml << 'INNEREOF'
app:
  name: user
  version: "1.0"
  env: dev
  host_display_name: RANTIPAY-USER
server:
  http:
    addr: 0.0.0.0:8000
    timeout: 60s
  grpc:
    addr: 0.0.0.0:9000
    timeout: 60s
data:
  database:
    driver: mysql
    source: root:youShouldChangeThis@tcp(mysqld:3306)/kit?parseTime=true&loc=Local&charset=utf8mb4&interpolateParams=true
  redis:
    addr: redis:6379
    password: youShouldChangeThis
    db: 0
  events:
    default:
      topic: kit
      addr: ""
      type: memory
  cache:
    - name: user_cache
      method: redis
      address: redis:6379
      password: youShouldChangeThis
      db: 0
security:
  jwt:
    expire_in: 2592000s # 30 days
    secret: youShouldChangeThis
  security_cookie:
    hash_key: youShouldChangeThis
  oidc:
    hydra:
      admin_url: http://hydra:4445
user:
  password_score_min: 0
  admin:
    username: admin@rantipay.com
    password: "Admin123!"
  idp: {}
logging:
  level: debug
  zap:
    level: debug
    outputPaths: ["stdout"]
    errorOutputPaths: ["stderr"]
    encoding: console
    encoderConfig:
      messageKey: message
      levelKey: level
      levelEncoder: lowercase
tracing:
  otel:
    enabled: false
INNEREOF
echo -e "${GREEN}✓ Archivo de configuración creado${NC}"
echo ""

# Crear Dockerfile para el servicio user
echo -e "${YELLOW}Creando Dockerfile para el servicio user...${NC}"
cat > kit/user/Dockerfile.local << 'INNEREOF'
FROM golang:1.20 AS builder

WORKDIR /app
COPY . .

# Compilar el servicio user
WORKDIR /app/user
RUN go mod download
RUN make build

FROM debian:stable-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
        && rm -rf /var/lib/apt/lists/ \
        && apt-get autoremove -y && apt-get autoclean -y

WORKDIR /app

# Copiar el binario compilado y archivos necesarios
COPY --from=builder /app/user/bin/user /app/
COPY --from=builder /app/user/i18n /app/i18n
COPY --from=builder /app/user/configs /app/configs

EXPOSE 8000
EXPOSE 9000

VOLUME /data/conf
CMD ["./user", "-conf", "/data/conf"]
INNEREOF
echo -e "${GREEN}✓ Dockerfile creado${NC}"
echo ""

# Compilar la imagen Docker del servicio user
echo -e "${YELLOW}Compilando la imagen Docker del servicio user...${NC}"
cd kit
docker build -t go-saas-kit-user:latest -f user/Dockerfile.local .
if [ $? -ne 0 ]; then
    echo -e "${RED}Error al compilar la imagen Docker${NC}"
    exit 1
fi
cd ..
echo -e "${GREEN}✓ Imagen Docker compilada exitosamente${NC}"
echo ""

# Actualizar el archivo docker-compose para usar la imagen completa
echo -e "${YELLOW}Actualizando el archivo docker-compose...${NC}"
cat > docker-compose-full-user.yml << 'INNEREOF'
services:
  # Infraestructura básica
  mysqld:
    image: mysql:8.0
    restart: always
    environment:
      - MYSQL_ROOT_PASSWORD=youShouldChangeThis
      - MYSQL_ROOT_HOST=%
      - MYSQL_DATABASE=kit
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3406:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost", "-u", "root", "-pyouShouldChangeThis"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  redis:
    image: redis:6.0
    restart: always
    command: redis-server --requirepass youShouldChangeThis
    ports:
      - "7379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "-a", "youShouldChangeThis", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  etcd:
    image: bitnami/etcd:3.5.0
    restart: always
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd:2379
    ports:
      - "3379:2379"
    volumes:
      - etcd_data:/bitnami/etcd
    healthcheck:
      test: ["CMD", "etcdctl", "endpoint", "health"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  # API Gateway con NGINX
  nginx:
    image: nginx:1.21
    ports:
      - "81:80"
    volumes:
      - ./nginx-gateway/nginx-full.conf:/etc/nginx/nginx.conf:ro
    restart: unless-stopped
    depends_on:
      - user
      - companies
    networks:
      - app-network

  # Servicio COMPLETO de usuario
  user:
    image: go-saas-kit-user:latest
    environment:
      - TZ=UTC
    ports:
      - "8000:8000"
      - "9000:9000"
    volumes:
      - ./configs/user:/data/conf
      - ./kit/.assets:/app/.assets
    depends_on:
      - mysqld
      - redis
      - etcd
    restart: unless-stopped
    networks:
      - app-network

  # Servicio Companies
  companies:
    build:
      context: ./companies-service
      dockerfile: Dockerfile
    environment:
      - TZ=UTC
    ports:
      - "8010:8010"
    depends_on:
      - mysqld
      - redis
      - etcd
    restart: unless-stopped
    networks:
      - app-network

  # Frontend
  web:
    image: goxiaoy/go-saas-kit-frontend:dev
    ports:
      - "8080:80"
    volumes:
      - ./kit-frontend/docker/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      - nginx
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  mysql_data:
  etcd_data:
INNEREOF
echo -e "${GREEN}✓ Archivo docker-compose actualizado${NC}"
echo ""

# Crear archivo de configuración NGINX para el servicio completo
echo -e "${YELLOW}Creando configuración NGINX para el servicio completo...${NC}"
mkdir -p nginx-gateway
cat > nginx-gateway/nginx-full.conf << 'INNEREOF'
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
    error_log   /var/log/nginx/error.log  debug;

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
        
        # Ruta health check para NGINX
        location = /health {
            access_log off;
            return 200 "NGINX Gateway Healthy\n";
        }
        
        # Todos los endpoints de User
        location /v1/ {
            proxy_pass http://user:8000/v1/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            
            # WebSocket support
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
        
        # Rutas para el servicio Companies
        location /v1/companies/ {
            proxy_pass http://companies:8010/api/v1/companies/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
        
        # Ruta health check del servicio Companies
        location = /v1/companies/health {
            proxy_pass http://companies:8010/health;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Ruta para assets estáticos
        location /assets/ {
            proxy_pass http://user:8000/assets/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
        
        # Ruta de fallback
        location / {
            return 404 'API Gateway: Endpoint not found';
        }
    }
}
INNEREOF
echo -e "${GREEN}✓ Configuración NGINX creada${NC}"
echo ""

# Crear script de inicio
echo -e "${YELLOW}Creando script de inicio...${NC}"
cat > start-full-user.sh << 'INNEREOF'
#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

DOCKER_COMPOSE_FILE="docker-compose-full-user.yml"

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Iniciando Rantipay SaaS con Servicio User Completo   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Paso 1: Detener todos los servicios
echo -e "${YELLOW}Paso 1: Deteniendo todos los servicios...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE down
echo -e "${GREEN}✓ Servicios detenidos${NC}"
echo ""

# Paso 2: Iniciar servicios de infraestructura primero
echo -e "${YELLOW}Paso 2: Iniciando servicios de infraestructura...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d mysqld redis etcd
sleep 10
echo -e "${GREEN}✓ Servicios de infraestructura iniciados${NC}"
echo ""

# Paso 3: Inicializar la base de datos
echo -e "${YELLOW}Paso 3: Inicializando base de datos...${NC}"
# Esperar a que MySQL esté disponible
for i in {1..30}; do
    if docker exec $(docker ps -q -f name=mysqld) mysqladmin -u root -pyouShouldChangeThis ping 2>/dev/null; then
        echo -e "${GREEN}MySQL está listo${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}Tiempo de espera agotado para MySQL${NC}"
        exit 1
    fi
    echo -n "."
    sleep 2
done

# Verificar si la base de datos existe
if ! docker exec $(docker ps -q -f name=mysqld) mysql -u root -pyouShouldChangeThis -e "USE kit;" 2>/dev/null; then
    echo -e "${YELLOW}Creando base de datos 'kit'...${NC}"
    docker exec $(docker ps -q -f name=mysqld) mysql -u root -pyouShouldChangeThis -e "CREATE DATABASE IF NOT EXISTS kit;"
    echo -e "${GREEN}✓ Base de datos creada${NC}"
else
    echo -e "${GREEN}✓ Base de datos 'kit' ya existe${NC}"
fi
echo -e "${GREEN}✓ Base de datos inicializada${NC}"
echo ""

# Paso 4: Iniciar el resto de servicios
echo -e "${YELLOW}Paso 4: Iniciando el resto de servicios...${NC}"
docker compose -f $DOCKER_COMPOSE_FILE up -d
echo -e "${GREEN}✓ Todos los servicios iniciados${NC}"
echo ""

# Paso 5: Verificar servicios
echo -e "${YELLOW}Paso 5: Verificando servicios...${NC}"
echo -e "${YELLOW}5.1: User Service:${NC}"
for i in {1..30}; do
    if curl -s http://localhost:8000/v1/user/health 2>/dev/null | grep -q "OK"; then
        echo -e "${GREEN}  ✓ User Service está funcionando correctamente${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}  ✗ User Service no está funcionando correctamente${NC}"
        echo -e "${YELLOW}  Revisando logs:${NC}"
        docker logs --tail 50 $(docker ps -q -f name=user)
    fi
    echo -n "."
    sleep 2
done

echo -e "${YELLOW}5.2: API Gateway:${NC}"
if curl -s http://localhost:81/health 2>/dev/null | grep -q "Healthy"; then
    echo -e "${GREEN}  ✓ API Gateway está funcionando correctamente${NC}"
else
    echo -e "${RED}  ✗ API Gateway no está funcionando correctamente${NC}"
    echo -e "${YELLOW}  Revisando logs:${NC}"
    docker logs --tail 20 $(docker ps -q -f name=nginx)
fi

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Sistema iniciado con User Service completo   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Frontend disponible en: http://localhost:8080${NC}"
echo -e "${GREEN}API Gateway disponible en: http://localhost:81${NC}"
echo -e "${GREEN}User Service disponible en: http://localhost:8000${NC}"
echo ""
echo -e "${YELLOW}Credenciales de inicio de sesión:${NC}"
echo -e "${YELLOW}Usuario: admin@rantipay.com${NC}"
echo -e "${YELLOW}Contraseña: Admin123!${NC}"
echo ""
echo -e "${YELLOW}Para detener todos los servicios:${NC}"
echo -e "${YELLOW}docker compose -f $DOCKER_COMPOSE_FILE down${NC}"
INNEREOF
chmod +x start-full-user.sh
echo -e "${GREEN}✓ Script de inicio creado${NC}"
echo ""

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Preparación completada   ${NC}"
echo -e "${GREEN}==============================================${NC}"
echo ""
echo -e "${GREEN}Ahora puedes iniciar el sistema con el servicio User completo:${NC}"
echo -e "${YELLOW}./start-full-user.sh${NC}"
echo ""
echo -e "${GREEN}Este script:${NC}"
echo -e "${GREEN}1. Construye la imagen del servicio user completo de go-saas/kit${NC}"
echo -e "${GREEN}2. Crea la configuración necesaria${NC}"
echo -e "${GREEN}3. Configura el API Gateway para dirigir todas las solicitudes al servicio user${NC}"
echo -e "${GREEN}4. Proporciona un script para iniciar todo el sistema${NC}"
