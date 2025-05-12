#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Configurando entorno de desarrollo Rantipay SaaS   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

# Crear directorios necesarios
mkdir -p configs/{user,saas,sys} data/assets

# Crear archivo docker-compose.yml
cat > docker-compose.yml << 'EOFDC'
version: '3'

services:
  # Infraestructura
  etcd:
    image: bitnami/etcd:3.5.0
    environment:
      - ALLOW_NONE_AUTHENTICATION=yes
      - ETCD_ADVERTISE_CLIENT_URLS=http://etcd:2379
    ports:
      - "2379:2379"
    volumes:
      - etcd_data:/bitnami/etcd
    networks:
      - rantipay-network

  mysql:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=rantipay123
      - MYSQL_ROOT_HOST=%
      - MYSQL_DATABASE=rantipay
    ports:
      - "3306:3306"
    volumes:
      - mysql_data:/var/lib/mysql
    networks:
      - rantipay-network

  redis:
    image: redis:6.0
    command: redis-server --requirepass rantipay123
    ports:
      - "6379:6379"
    networks:
      - rantipay-network

  # API Gateway
  apisix:
    image: apache/apisix:2.15.0-alpine
    volumes:
      - ./kit/deploy/apisix/config.yaml:/usr/local/apisix/conf/config.yaml:ro
      - ./kit/deploy/apisix/apisix.yaml:/usr/local/apisix/conf/apisix.yaml:ro
    ports:
      - "9080:9080"
      - "9180:9180"
    depends_on:
      - etcd
    networks:
      - rantipay-network

  apisix-dashboard:
    image: apache/apisix-dashboard:2.15.0-alpine
    volumes:
      - ./kit/deploy/apisix/dashboard_conf/conf.yaml:/usr/local/apisix-dashboard/conf/conf.yaml:ro
    ports:
      - "9000:9000"
    depends_on:
      - apisix
    networks:
      - rantipay-network

  # Servicios base (usando imágenes oficiales)
  user:
    image: goxiaoy/go-saas-kit-user:latest
    volumes:
      - ./configs/user:/data/conf
      - ./data/assets:/app/.assets
    ports:
      - "8000:8000"
      - "9000:9000"
    depends_on:
      - mysql
      - redis
      - etcd
    networks:
      - rantipay-network

  saas:
    image: goxiaoy/go-saas-kit-saas:latest
    volumes:
      - ./configs/saas:/data/conf
      - ./data/assets:/app/.assets
    ports:
      - "8001:8000"
      - "9001:9000"
    depends_on:
      - mysql
      - redis
      - etcd
      - user
    networks:
      - rantipay-network

  sys:
    image: goxiaoy/go-saas-kit-sys:latest
    volumes:
      - ./configs/sys:/data/conf
      - ./data/assets:/app/.assets
    ports:
      - "8002:8000"
      - "9002:9000"
    depends_on:
      - mysql
      - redis
      - etcd
      - user
      - saas
    networks:
      - rantipay-network

  # Frontend
  web:
    image: goxiaoy/go-saas-kit-frontend:dev
    ports:
      - "8080:80"
    depends_on:
      - apisix
    networks:
      - rantipay-network

networks:
  rantipay-network:
    driver: bridge

volumes:
  mysql_data:
  etcd_data:
EOFDC

# Crear configuraciones para los servicios
cat > configs/user/config.yaml << 'EOF'
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
services:
  registry:
    type: etcd
    endpoint: http://etcd:2379
data:
  endpoints:
    databases:
      default:
        driver: mysql
        source: root:rantipay123@tcp(mysql:3306)/rantipay?parseTime=true&loc=Local&charset=utf8mb4&interpolateParams=true
    redis:
      default:
        addrs: ["redis:6379"]
        password: rantipay123
    email: {}
    events:
      default:
        topic: kit
        addr: ""
        type: memory
      user:
        group: user-golang
  vfs:
    -
      public_url: http://localhost/assets
      mount_path: "/"
      os:
        dir: ".assets"
security:
  jwt:
    expire_in: 2592000s # 30 days
    secret: rantipay-jwt-super-secret-key
  security_cookie:
    hash_key: rantipay-cookie-hash-key
user:
  password_score_min: 0
  admin:
    username: admin@rantipay.com
    password: "Admin123!"
  idp: {}
logging:
  level: debug
