#!/bin/bash

# Script para verificar el estado de los servicios con Hot Reload
# Este script ayuda a diagnosticar problemas cuando los servicios están en ejecución
# pero no responden correctamente (error 503)

echo "🔍 Verificando estado de los servicios con Hot Reload..."

PROJECT_ROOT=~/developer/projects/rantipay/wankarlab/rantipay-saas/kit

# Verificar si los procesos están ejecutándose
echo "🔄 Verificando procesos..."
for service in "user" "saas" "sys"; do
    if [ -f "$PROJECT_ROOT/logs/$service.pid" ]; then
        PID=$(cat "$PROJECT_ROOT/logs/$service.pid")
        if ps -p $PID > /dev/null; then
            echo "✅ Proceso $service (PID: $PID) está en ejecución"
        else
            echo "❌ Proceso $service (PID: $PID) NO está en ejecución"
        fi
    else
        echo "❌ No se encontró archivo PID para $service"
    fi
done

# Verificar conectividad directa con los servicios
echo "🔄 Verificando conectividad directa a los servicios..."
for port in 8000 8001 8002; do
    service_name=""
    case $port in
        8000) service_name="user" ;;
        8001) service_name="saas" ;;
        8002) service_name="sys" ;;
    esac
    
    if curl -s -I "http://localhost:$port" > /dev/null; then
        echo "✅ Servicio $service_name en puerto $port responde correctamente"
    else
        echo "❌ Servicio $service_name en puerto $port NO responde"
    fi
done

# Verificar rutas en APISIX
echo "🔄 Verificando rutas en APISIX..."
for route in "user-dev" "saas-dev" "sys-dev"; do
    ROUTE_INFO=$(curl -s "http://localhost:9280/apisix/admin/routes/$route" -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1")
    if echo "$ROUTE_INFO" | grep -q "nodes"; then
        echo "✅ Ruta $route configurada correctamente en APISIX"
        echo "   Detalles: $ROUTE_INFO"
    else
        echo "❌ Problema con la ruta $route en APISIX"
        echo "   Respuesta: $ROUTE_INFO"
    fi
done

# Verificar configuración de host.docker.internal en APISIX
echo "🔄 Verificando resolución de host.docker.internal desde APISIX..."
docker exec kit-apisix-1 ping -c 1 host.docker.internal 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ APISIX puede resolver host.docker.internal"
else
    echo "❌ APISIX NO puede resolver host.docker.internal"
    echo "⚠️ Esto puede ser la causa del error 503"
    echo "🔄 Verificando si existe la entrada en /etc/hosts dentro del contenedor..."
    docker exec kit-apisix-1 grep -q "host.docker.internal" /etc/hosts
    if [ $? -eq 0 ]; then
        echo "✅ Entrada host.docker.internal existe en /etc/hosts"
    else
        echo "❌ Entrada host.docker.internal NO existe en /etc/hosts"
        echo "🔄 Vamos a agregarla..."
        echo "⚠️ Necesitamos reiniciar el contenedor APISIX con la opción --add-host"
    fi
fi

# Mostrar los últimos logs de cada servicio
echo "📝 Últimas líneas de los logs de servicios:"
for service in "user" "saas" "sys"; do
    echo "--- Log de $service ---"
    if [ -f "$PROJECT_ROOT/logs/$service-hotreload.log" ]; then
        tail -n 10 "$PROJECT_ROOT/logs/$service-hotreload.log"
    else
        echo "❌ No se encontró archivo de log para $service"
    fi
    echo ""
done

echo "🔍 Diagnóstico completado."