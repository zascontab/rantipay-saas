#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Compilando servicios core de go-saas/kit   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

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
    endpoint: http://localhost:2379
data:
  endpoints:
    databases:
      default:
        driver: mysql
        source: root:rantipay123@tcp(localhost:3306)/rantipay?parseTime=true&loc=Local&charset=utf8mb4&interpolateParams=true
    redis:
      default:
        addrs: ["localhost:6379"]
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
EOF

cat > configs/saas/config.yaml << 'EOF'
app:
  name: saas
  version: "1.0"
  env: dev
  host_display_name: RANTIPAY-SAAS
server:
  http:
    addr: 0.0.0.0:8001
    timeout: 60s
  grpc:
    addr: 0.0.0.0:9001
    timeout: 60s
services:
  registry:
    type: etcd
    endpoint: http://localhost:2379
  endpoints:
    user:
      address: localhost:9000
data:
  endpoints:
    databases:
      default:
        driver: mysql
        source: root:rantipay123@tcp(localhost:3306)/rantipay?parseTime=true&loc=Local&charset=utf8mb4&interpolateParams=true
    redis:
      default:
        addrs: ["localhost:6379"]
        password: rantipay123
    email: {}
    events:
      default:
        topic: kit
        addr: ""
        type: memory
      saas:
        group: saas-golang
security:
  jwt:
    expire_in: 2592000s # 30 days
    secret: rantipay-jwt-super-secret-key
logging:
  level: debug
EOF

cat > configs/sys/config.yaml << 'EOF'
app:
  name: sys
  version: "1.0"
  env: dev
  host_display_name: RANTIPAY-SYS
server:
  http:
    addr: 0.0.0.0:8002
    timeout: 60s
  grpc:
    addr: 0.0.0.0:9002
    timeout: 60s
services:
  registry:
    type: etcd
    endpoint: http://localhost:2379
  endpoints:
    user:
      address: localhost:9000
    tenant:
      address: localhost:9001
data:
  endpoints:
    databases:
      default:
        driver: mysql
        source: root:rantipay123@tcp(localhost:3306)/rantipay?parseTime=true&loc=Local&charset=utf8mb4&interpolateParams=true
    redis:
      default:
        addrs: ["localhost:6379"]
        password: rantipay123
    email: {}
    events:
      default:
        topic: kit
        addr: ""
        type: memory
      sys:
        group: sys-golang
security:
  jwt:
    expire_in: 2592000s # 30 days
    secret: rantipay-jwt-super-secret-key
logging:
  level: debug
sys:
  apisix:
    endpoint: http://localhost:9180
    api_key: edd1c9f034335f136f87ad84b625c8f1
EOF

echo -e "${GREEN}✓ Archivos de configuración creados${NC}"
echo ""

# Compilar servicio User
echo -e "${YELLOW}Compilando servicio User...${NC}"
cd kit/user
go mod tidy
mkdir -p bin
go build -o bin/user ./cmd/server
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al compilar el servicio User${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicio User compilado correctamente${NC}"
cd ../..

# Compilar servicio SaaS
echo -e "${YELLOW}Compilando servicio SaaS...${NC}"
cd kit/saas
go mod tidy
mkdir -p bin
go build -o bin/saas ./cmd/server
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al compilar el servicio SaaS${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicio SaaS compilado correctamente${NC}"
cd ../..

# Compilar servicio Sys
echo -e "${YELLOW}Compilando servicio Sys...${NC}"
cd kit/sys
go mod tidy
mkdir -p bin
go build -o bin/sys ./cmd/server
if [ $? -ne 0 ]; then
    echo -e "${RED}× Error al compilar el servicio Sys${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Servicio Sys compilado correctamente${NC}"
cd ../..

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   Servicios core compilados correctamente   ${NC}"
echo -e "${GREEN}==============================================${NC}"