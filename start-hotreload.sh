#!/bin/bash

# Script de Hot Reload para Go-SAAS-Kit con resolución de problemas de archivos
# Este script maneja específicamente el error "no such file or directory"

set -e  # Detener el script si hay algún error

echo "🔍 Iniciando configuración de Hot Reload con resolución de problemas de archivos..."

# Verificar la estructura de directorios
PROJECT_ROOT=~/developer/projects/rantipay/wankarlab/rantipay-saas/kit
if [ ! -d "$PROJECT_ROOT" ]; then
    echo "❌ ERROR: El directorio del proyecto no existe: $PROJECT_ROOT"
    echo "Por favor, actualiza la ruta en este script para que coincida con tu entorno."
    exit 1
fi

# Crear directorios necesarios
mkdir -p $PROJECT_ROOT/logs
mkdir -p $PROJECT_ROOT/user/tmp
mkdir -p $PROJECT_ROOT/saas/tmp
mkdir -p $PROJECT_ROOT/sys/tmp

# Verificar que CompileDaemon esté instalado
if ! command -v CompileDaemon &> /dev/null; then
    echo "📦 Instalando CompileDaemon..."
    go install github.com/githubnemo/CompileDaemon@latest
fi

# Detener los servicios que vamos a reemplazar
echo "🛑 Deteniendo servicios que serán reemplazados..."
docker stop kit-user-1 kit-saas-1 kit-sys-1 || true

# Matar cualquier proceso previo de CompileDaemon
echo "🧹 Limpiando procesos anteriores de CompileDaemon..."
pkill -f "CompileDaemon" || true

# PARTE NUEVA: Crear directorios y archivos requeridos
echo "🔧 Verificando directorios críticos..."

# Para user service
mkdir -p $PROJECT_ROOT/user/configs
mkdir -p $PROJECT_ROOT/user/tmp
mkdir -p $PROJECT_ROOT/user/internal/data
mkdir -p $PROJECT_ROOT/user/internal/biz
mkdir -p $PROJECT_ROOT/user/internal/service
mkdir -p $PROJECT_ROOT/user/internal/server

# Para saas service
mkdir -p $PROJECT_ROOT/saas/configs
mkdir -p $PROJECT_ROOT/saas/tmp
mkdir -p $PROJECT_ROOT/saas/internal/data
mkdir -p $PROJECT_ROOT/saas/internal/biz
mkdir -p $PROJECT_ROOT/saas/internal/service
mkdir -p $PROJECT_ROOT/saas/internal/server

# Para sys service
mkdir -p $PROJECT_ROOT/sys/configs
mkdir -p $PROJECT_ROOT/sys/tmp
mkdir -p $PROJECT_ROOT/sys/internal/data
mkdir -p $PROJECT_ROOT/sys/internal/biz
mkdir -p $PROJECT_ROOT/sys/internal/service
mkdir -p $PROJECT_ROOT/sys/internal/server

# Función para encontrar el archivo mencionado en el error
find_file_in_error() {
    SERVICE=$1
    LOG_FILE="$PROJECT_ROOT/logs/$SERVICE-hotreload.log"
    
    if [ -f "$LOG_FILE" ]; then
        # Buscar patrones de error de archivo no encontrado
        FILE_PATH=$(grep -oP "no such file or directory: \K.*" "$LOG_FILE" 2>/dev/null || true)
        if [ -z "$FILE_PATH" ]; then
            FILE_PATH=$(grep -oP "panic: \K.*" "$LOG_FILE" | grep -i "file" 2>/dev/null || true)
        fi
        
        if [ -n "$FILE_PATH" ]; then
            echo "⚠️ Archivo no encontrado en $SERVICE: $FILE_PATH"
            DIR_PATH=$(dirname "$FILE_PATH")
            echo "🔧 Creando directorio: $DIR_PATH"
            mkdir -p "$DIR_PATH"
        fi
    fi
}

# Verificar logs anteriores para problemas de archivos
for service in "user" "saas" "sys"; do
    find_file_in_error $service
done

# Crear versiones de configuración para cada servicio
echo "🔧 Creando archivos de configuración para cada servicio..."

# Para user service
cat > $PROJECT_ROOT/user/configs/config.yaml << EOF
server:
  http:
    addr: 0.0.0.0:8000
    timeout: 1s
  grpc:
    addr: 0.0.0.0:9000
    timeout: 1s
data:
  database:
    driver: mysql
    source: root:youShouldChangeThis@tcp(localhost:3406)/user_db
  redis:
    addr: localhost:7379
    password: youShouldChangeThis
    read_timeout: 0.2s
    write_timeout: 0.2s
EOF

# Para saas service
cat > $PROJECT_ROOT/saas/configs/config.yaml << EOF
server:
  http:
    addr: 0.0.0.0:8001
    timeout: 1s
  grpc:
    addr: 0.0.0.0:9001
    timeout: 1s
data:
  database:
    driver: mysql
    source: root:youShouldChangeThis@tcp(localhost:3406)/saas_db
  redis:
    addr: localhost:7379
    password: youShouldChangeThis
    read_timeout: 0.2s
    write_timeout: 0.2s
EOF

# Para sys service
cat > $PROJECT_ROOT/sys/configs/config.yaml << EOF
server:
  http:
    addr: 0.0.0.0:8002
    timeout: 1s
  grpc:
    addr: 0.0.0.0:9002
    timeout: 1s
data:
  database:
    driver: mysql
    source: root:youShouldChangeThis@tcp(localhost:3406)/sys_db
  redis:
    addr: localhost:7379
    password: youShouldChangeThis
    read_timeout: 0.2s
    write_timeout: 0.2s
EOF

# Función para iniciar un servicio con Hot Reload
start_service_with_debug() {
    SERVICE_NAME=$1
    MAIN_PATH=$2
    CONFIG_PATH=$3
    PORT=$4
    DB_NAME=$5

    echo "🚀 Iniciando $SERVICE_NAME con Hot Reload en puerto $PORT (modo debug)..."
    cd $PROJECT_ROOT/$SERVICE_NAME
    
    # Verificar el archivo main.go
    if [ ! -f "$MAIN_PATH" ]; then
        echo "❌ ERROR: Archivo principal no encontrado: $MAIN_PATH"
        return 1
    fi
    
    # Crear el archivo de script de entorno con debug activado
    ENV_SCRIPT="./tmp/env.sh"
    echo "#!/bin/bash" > $ENV_SCRIPT
    echo "export DATA_DATABASE_SOURCE=\"root:youShouldChangeThis@tcp(localhost:3406)/$DB_NAME\"" >> $ENV_SCRIPT
    echo "export ETCD_ADDRESS=\"localhost:3379\"" >> $ENV_SCRIPT
    echo "export SERVER_HTTP_ADDR=\"0.0.0.0:$PORT\"" >> $ENV_SCRIPT
    echo "export REDIS_ADDR=\"localhost:7379\"" >> $ENV_SCRIPT
    echo "export REDIS_PASSWORD=\"youShouldChangeThis\"" >> $ENV_SCRIPT
    echo "export LOG_LEVEL=\"debug\"" >> $ENV_SCRIPT
    echo "export GO_DEBUG=\"1\"" >> $ENV_SCRIPT
    echo "exec \"\$@\"" >> $ENV_SCRIPT
    chmod +x $ENV_SCRIPT
    
    # Verificar si estamos usando configs locales o globales
    if [ -f "./configs/config.yaml" ]; then
        LOCAL_CONFIG="./configs/config.yaml"
        USING_LOCAL="true"
    else
        LOCAL_CONFIG="$CONFIG_PATH"
        USING_LOCAL="false"
    fi
    
    echo "📝 Iniciando $SERVICE_NAME con:"
    echo "   - Archivo principal: $MAIN_PATH"
    echo "   - Archivo de configuración: $LOCAL_CONFIG"
    echo "   - Usando config local: $USING_LOCAL"
    echo "   - Puerto: $PORT"
    
    # Probar primero con configuración local
    if [ "$USING_LOCAL" = "true" ]; then
        echo "🔍 Intentando con la configuración local..."
        nohup CompileDaemon \
            --build="go build -o ./tmp/main $MAIN_PATH" \
            --command="./tmp/env.sh ./tmp/main -conf ./configs/config.yaml" \
            --directory="./" \
            --pattern="(.+\.go|.+\.yaml)$" \
            --color=true \
            --graceful-kill=true \
            --verbose \
            > $PROJECT_ROOT/logs/$SERVICE_NAME-hotreload.log 2>&1 &
    else
        echo "🔍 Intentando con la configuración global..."
        nohup CompileDaemon \
            --build="go build -o ./tmp/main $MAIN_PATH" \
            --command="./tmp/env.sh ./tmp/main -conf $CONFIG_PATH" \
            --directory="./" \
            --pattern="(.+\.go|.+\.yaml)$" \
            --color=true \
            --graceful-kill=true \
            --verbose \
            > $PROJECT_ROOT/logs/$SERVICE_NAME-hotreload.log 2>&1 &
    fi
    
    SERVICE_PID=$!
    echo $SERVICE_PID > $PROJECT_ROOT/logs/$SERVICE_NAME.pid
    
    # Dar un poco más de tiempo para iniciar
    sleep 5
    
    # Verificar si el proceso sigue vivo
    if ps -p $SERVICE_PID > /dev/null; then
        echo "✅ $SERVICE_NAME iniciado exitosamente (PID: $SERVICE_PID)"
    else
        echo "❌ ERROR: $SERVICE_NAME no pudo iniciarse."
        echo "📝 Últimas líneas del log:"
        tail -n 20 $PROJECT_ROOT/logs/$SERVICE_NAME-hotreload.log
    fi
}

# Iniciar los servicios con Hot Reload y modo debug
echo "🚀 Iniciando servicios con Hot Reload (modo debug)..."

# Iniciar user service
start_service_with_debug "user" "./cmd/user/main.go" "$PROJECT_ROOT/configs.dev/config.yaml" "8000" "user_db"

# Iniciar saas service
start_service_with_debug "saas" "./cmd/saas/main.go" "$PROJECT_ROOT/configs.dev/config.yaml" "8001" "saas_db"

# Iniciar sys service
start_service_with_debug "sys" "./cmd/sys/main.go" "$PROJECT_ROOT/configs.dev/config.yaml" "8002" "sys_db"

# Esperar a que los servicios se inicien completamente
echo "⏳ Esperando a que los servicios se estabilicen..."
sleep 5

# Verificar si los servicios están funcionando
for service in "user" "saas" "sys"; do
    port=""
    case $service in
        user) port=8000 ;;
        saas) port=8001 ;;
        sys)  port=8002 ;;
    esac
    
    if curl -s -I "http://localhost:$port" > /dev/null; then
        echo "✅ Servicio $service en puerto $port está funcionando correctamente"
    else
        echo "⚠️ Servicio $service en puerto $port no responde. Verificando logs..."
        tail -n 20 $PROJECT_ROOT/logs/$service-hotreload.log
    fi
done

# Configurar APISIX para redireccionar a los servicios locales
echo "🔄 Configurando APISIX para redireccionar a los servicios locales..."

# Obtener la IP interna de la máquina
INTERNAL_IP=$(hostname -I | awk '{print $1}')
echo "ℹ️ Usando IP interna: $INTERNAL_IP"

# Ruta para user service
echo "🔄 Configurando ruta para User service..."
curl -s http://localhost:9280/apisix/admin/routes/user-dev -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"/user/*\",
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"$INTERNAL_IP:8000\": 1
    }
  }
}"

# Ruta para saas service
echo "🔄 Configurando ruta para SAAS service..."
curl -s http://localhost:9280/apisix/admin/routes/saas-dev -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"/saas/*\",
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"$INTERNAL_IP:8001\": 1
    }
  }
}"

# Ruta para sys service
echo "🔄 Configurando ruta para SYS service..."
curl -s http://localhost:9280/apisix/admin/routes/sys-dev -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1" -X PUT -d "{
  \"uri\": \"/sys/*\",
  \"upstream\": {
    \"type\": \"roundrobin\",
    \"nodes\": {
      \"$INTERNAL_IP:8002\": 1
    }
  }
}"

# Información de acceso
echo ""
echo "⚠️ IMPORTANTE: Si sigues viendo errores, verifica estos logs para obtener más detalles:"
echo "   - User: tail -f $PROJECT_ROOT/logs/user-hotreload.log"
echo "   - SAAS: tail -f $PROJECT_ROOT/logs/saas-hotreload.log"
echo "   - SYS: tail -f $PROJECT_ROOT/logs/sys-hotreload.log"
echo ""
echo "✅ Entorno de desarrollo con Hot Reload configurado correctamente"
echo "================================================================="
echo "🌐 Frontend: http://localhost"
echo "📚 API Docs: http://localhost/swagger"
echo "🔧 APISIX Dashboard: http://localhost:9000"
echo ""
echo "🧪 Acceso directo a servicios con Hot Reload:"
echo "   - User API: http://localhost:8000"
echo "   - SAAS API: http://localhost:8001"
echo "   - SYS API: http://localhost:8002"
echo ""
echo "⚠️ Para detener el Hot Reload y volver a los servicios Docker:"
echo "   ./stop-hotreload.sh"
echo "================================================================="