#!/bin/bash

echo "🛑 Deteniendo servicios con Hot Reload..."

# Detener los procesos de CompileDaemon
if [ -f ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/user.pid ]; then
    PID=$(cat ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/user.pid)
    echo "🔄 Deteniendo User Service (PID: $PID)..."
    kill $PID 2>/dev/null || true
    rm ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/user.pid
fi

if [ -f ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/saas.pid ]; then
    PID=$(cat ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/saas.pid)
    echo "🔄 Deteniendo SAAS Service (PID: $PID)..."
    kill $PID 2>/dev/null || true
    rm ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/saas.pid
fi

if [ -f ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/sys.pid ]; then
    PID=$(cat ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/sys.pid)
    echo "🔄 Deteniendo SYS Service (PID: $PID)..."
    kill $PID 2>/dev/null || true
    rm ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/logs/sys.pid
fi

# Por si quedó algún proceso CompileDaemon
echo "🔍 Buscando otros procesos de CompileDaemon..."
pkill -f "CompileDaemon" || true

# Eliminar las rutas de desarrollo de APISIX
echo "🔄 Eliminando rutas de desarrollo de APISIX..."
curl -X DELETE http://localhost:9280/apisix/admin/routes/user-dev -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1"
curl -X DELETE http://localhost:9280/apisix/admin/routes/saas-dev -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1"
curl -X DELETE http://localhost:9280/apisix/admin/routes/sys-dev -H "X-API-KEY: edd1c9f034335f136f87ad84b625c8f1"

# Reiniciar los servicios originales de Docker
echo "🔄 Reiniciando los servicios originales de Docker..."
cd ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit
docker start kit-user-1 kit-saas-1 kit-sys-1

echo "✅ Servicios con Hot Reload detenidos y servicios originales reiniciados."
echo "🌐 La aplicación debería estar disponible nuevamente a través de los contenedores Docker."