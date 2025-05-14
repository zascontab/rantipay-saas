#!/bin/bash

# Este script te permite reiniciar rápidamente un servicio específico
# Uso: ./restart-service.sh [user|saas|sys]

if [ -z "$1" ]; then
    echo "❌ Error: Debes especificar qué servicio reiniciar (user, saas o sys)"
    echo "Uso: ./restart-service.sh [user|saas|sys]"
    exit 1
fi

SERVICE=$1

if [[ ! "$SERVICE" =~ ^(user|saas|sys)$ ]]; then
    echo "❌ Error: Servicio no válido. Opciones: user, saas, sys"
    exit 1
fi

echo "🔄 Reiniciando servicio $SERVICE..."

# Detener el proceso actual
if [ -f ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/$SERVICE.pid ]; then
    PID=$(cat ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/$SERVICE.pid)
    echo "🛑 Deteniendo $SERVICE (PID: $PID)..."
    kill $PID 2>/dev/null || true
    rm ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/$SERVICE.pid
else
    echo "⚠️ No se encontró un PID para $SERVICE. Buscando procesos..."
    pkill -f "CompileDaemon.*$SERVICE" || true
fi

# Configurar parámetros según el servicio
case $SERVICE in
    user)
        MAIN_PATH="./cmd/user/main.go"
        CONFIG_PATH="../configs.dev/config.yaml"
        PORT="8000"
        DB_NAME="user_db"
        ;;
    saas)
        MAIN_PATH="./cmd/saas/main.go"
        CONFIG_PATH="../configs.dev/saas.yaml"
        PORT="8001"
        DB_NAME="saas_db"
        ;;
    sys)
        MAIN_PATH="./cmd/sys/main.go"
        CONFIG_PATH="../configs.dev/sys.yaml"
        PORT="8002"
        DB_NAME="sys_db"
        ;;
esac

# Reiniciar el servicio
cd ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/$SERVICE
mkdir -p ./tmp
mkdir -p ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs

echo "🚀 Iniciando $SERVICE con Hot Reload..."
nohup CompileDaemon \
    --build="go build -o ./tmp/main $MAIN_PATH" \
    --command="./tmp/main -conf $CONFIG_PATH" \
    --directory="./" \
    --pattern="(.+\.go|.+\.yaml)$" \
    --color=true \
    --graceful-kill=true \
    --log-prefix=false \
    --env="DATA_DATABASE_SOURCE=root:youShouldChangeThis@tcp(localhost:3406)/$DB_NAME;ETCD_ADDRESS=localhost:3379;SERVER_HTTP_ADDR=0.0.0.0:$PORT;REDIS_ADDR=localhost:7379;REDIS_PASSWORD=youShouldChangeThis" \
    > ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/$SERVICE-hotreload.log 2>&1 &

# Guardar el PID
echo $! > ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/$SERVICE.pid

echo "✅ Servicio $SERVICE reiniciado correctamente (PID: $!)"
echo "🔍 Para ver los logs: tail -f ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/$SERVICE-hotreload.log"