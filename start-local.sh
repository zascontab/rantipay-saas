#!/bin/bash

# Obtener ruta base del proyecto
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Crear bases de datos si no existen
echo "Creando bases de datos..."
docker exec -it kit-mysqld-1 mysql -u root -pyouShouldChangeThis -e "CREATE DATABASE IF NOT EXISTS user_db"
docker exec -it kit-mysqld-1 mysql -u root -pyouShouldChangeThis -e "CREATE DATABASE IF NOT EXISTS saas_db"
docker exec -it kit-mysqld-1 mysql -u root -pyouShouldChangeThis -e "CREATE DATABASE IF NOT EXISTS sys_db"

# Iniciar servicio user
echo "Iniciando servicio user..."
cd $PROJECT_ROOT/kit/user
export DATA_DATABASE_SOURCE="root:youShouldChangeThis@tcp(localhost:3406)/user_db"
export ETCD_ADDRESS="localhost:3379"
export SERVER_HTTP_ADDR="0.0.0.0:8000"
export REDIS_ADDR="localhost:7379"
export REDIS_PASSWORD="youShouldChangeThis"
go run cmd/user/main.go -conf $PROJECT_ROOT/kit/configs.dev/config.yaml &

# Iniciar servicio saas
echo "Iniciando servicio saas..."
cd $PROJECT_ROOT/kit/saas
export DATA_DATABASE_SOURCE="root:youShouldChangeThis@tcp(localhost:3406)/saas_db"
export ETCD_ADDRESS="localhost:3379"
export SERVER_HTTP_ADDR="0.0.0.0:8001"
export REDIS_ADDR="localhost:7379"
export REDIS_PASSWORD="youShouldChangeThis"
go run cmd/saas/main.go -conf $PROJECT_ROOT/kit/configs.dev/config.yaml &

# Iniciar servicio sys
echo "Iniciando servicio sys..."
cd $PROJECT_ROOT/kit/sys
export DATA_DATABASE_SOURCE="root:youShouldChangeThis@tcp(localhost:3406)/sys_db"
export ETCD_ADDRESS="localhost:3379"
export SERVER_HTTP_ADDR="0.0.0.0:8002"
export REDIS_ADDR="localhost:7379"
export REDIS_PASSWORD="youShouldChangeThis"
go run cmd/sys/main.go -conf $PROJECT_ROOT/kit/configs.dev/sys.yaml &

echo "Todos los servicios iniciados."
echo "Frontend disponible en: http://localhost:9000/"
echo "Para acceder directamente a los servicios:"
echo "- User service: http://localhost:8000"
echo "- Saas service: http://localhost:8001"
echo "- Sys service: http://localhost:8002"
