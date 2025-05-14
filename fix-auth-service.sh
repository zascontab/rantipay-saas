#!/bin/bash

# Script para corregir el Auth Service y usar otro puerto

echo "🔧 Corrigiendo la configuración del Auth Service..."

PROJECT_ROOT=~/developer/projects/rantipay/wankarlab/rantipay-saas/kit
AUTH_DIR="$PROJECT_ROOT/docker-auth-dev"
NEW_PORT=8081 # Usar puerto 8081 en lugar de 8080

# Verificar directorio
if [ ! -d "$AUTH_DIR" ]; then
    echo "❌ El directorio $AUTH_DIR no existe. Ejecuta primero auth-service-dev.sh"
    exit 1
fi

cd $AUTH_DIR

# Modificar el script rebuild.sh para usar otro puerto
echo "🔧 Actualizando script rebuild.sh para usar el puerto $NEW_PORT..."
cat > rebuild.sh << EOF
#!/bin/bash

# Detener contenedor si existe
docker stop auth-service-dev 2>/dev/null || true
docker rm auth-service-dev 2>/dev/null || true

# Reconstruir la imagen
echo "🔨 Reconstruyendo imagen de Auth Service..."
docker build -t auth-service-dev .

# Ejecutar el contenedor con puertos expuestos
echo "🚀 Iniciando Auth Service en el puerto $NEW_PORT..."
docker run -d --name auth-service-dev -p $NEW_PORT:80 --network kit_default auth-service-dev

echo "✅ Auth Service reiniciado en http://localhost:$NEW_PORT"
echo "📝 Endpoints disponibles:"
echo "   - GET / - Información del API"
echo "   - POST /api/auth/signup - Registro con email o teléfono"
echo "   - POST /api/auth/signin - Inicio de sesión con email o teléfono"
echo "   - POST /api/auth/otp/send - Enviar código OTP al teléfono"
echo "   - POST /api/auth/otp/verify - Verificar código OTP"
echo "   - GET /api/auth/users - Listar usuarios (solo desarrollo)"
EOF

chmod +x rebuild.sh

# Modificar el script test_api.sh para usar otro puerto
echo "🔧 Actualizando script test_api.sh para usar el puerto $NEW_PORT..."
cat > test_api.sh << EOF
#!/bin/bash

API_URL="http://localhost:$NEW_PORT"

# Función para mostrar resultados
show_response() {
  echo -e "\n🔍 Respuesta:"
  echo "\$1" | jq -r '.'
  echo -e "\n------------------------------------"
}

# 1. Información del API
echo -e "\n🚀 Obteniendo información del API..."
RESPONSE=\$(curl -s \$API_URL/)
show_response "\$RESPONSE"

# 2. Registro con email
echo -e "🚀 Registrando usuario con email..."
RESPONSE=\$(curl -s -X POST \$API_URL/api/auth/signup \\
  -H "Content-Type: application/json" \\
  -d '{"email":"test@example.com","password":"secret123"}')
show_response "\$RESPONSE"

# 3. Registro con teléfono
echo -e "🚀 Registrando usuario con teléfono..."
RESPONSE=\$(curl -s -X POST \$API_URL/api/auth/signup \\
  -H "Content-Type: application/json" \\
  -d '{"phone":"+123456789","password":"secret123"}')
show_response "\$RESPONSE"

# 4. Enviar OTP
echo -e "🚀 Enviando código OTP..."
RESPONSE=\$(curl -s -X POST \$API_URL/api/auth/otp/send \\
  -H "Content-Type: application/json" \\
  -d '{"phone":"+123456789"}')
show_response "\$RESPONSE"

# 5. Verificar OTP
echo -e "🚀 Verificando código OTP..."
RESPONSE=\$(curl -s -X POST \$API_URL/api/auth/otp/verify \\
  -H "Content-Type: application/json" \\
  -d '{"phone":"+123456789","code":"123456"}')
show_response "\$RESPONSE"

# 6. Iniciar sesión con email
echo -e "🚀 Iniciando sesión con email..."
RESPONSE=\$(curl -s -X POST \$API_URL/api/auth/signin \\
  -H "Content-Type: application/json" \\
  -d '{"email":"test@example.com","password":"secret123"}')
show_response "\$RESPONSE"

# 7. Iniciar sesión con teléfono y OTP
echo -e "🚀 Iniciando sesión con teléfono y OTP..."
RESPONSE=\$(curl -s -X POST \$API_URL/api/auth/otp/send \\
  -H "Content-Type: application/json" \\
  -d '{"phone":"+123456789"}')
OTP_CODE=\$(echo \$RESPONSE | jq -r '.data.code')
RESPONSE=\$(curl -s -X POST \$API_URL/api/auth/signin \\
  -H "Content-Type: application/json" \\
  -d "{\"phone\":\"+123456789\",\"otp_code\":\"\$OTP_CODE\"}")
show_response "\$RESPONSE"

# 8. Listar usuarios
echo -e "🚀 Listando usuarios..."
RESPONSE=\$(curl -s \$API_URL/api/auth/users)
show_response "\$RESPONSE"
EOF

chmod +x test_api.sh

# Ejecutar el script rebuild para iniciar el contenedor en el nuevo puerto
echo "🚀 Reconstruyendo y reiniciando el Auth Service en el puerto $NEW_PORT..."
./rebuild.sh

echo ""
echo "✅ Auth Service corregido y reiniciado en http://localhost:$NEW_PORT"
echo "📝 Para probar el API, ejecuta: ./test_api.sh"
echo "📝 Si continúas teniendo problemas de puerto, verifica qué procesos están usando el puerto:"
echo "   sudo lsof -i:$NEW_PORT"
echo ""
echo "🔍 Info de depuración:"
echo "📌 Contenedores en ejecución:"
docker ps