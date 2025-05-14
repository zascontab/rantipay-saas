#!/bin/bash

# Detener contenedor si existe
docker stop auth-service-dev 2>/dev/null || true
docker rm auth-service-dev 2>/dev/null || true

# Reconstruir la imagen
echo "🔨 Reconstruyendo imagen de Auth Service..."
docker build -t auth-service-dev .

# Ejecutar el contenedor con puertos expuestos
echo "🚀 Iniciando Auth Service en el puerto 8081..."
docker run -d --name auth-service-dev -p 8081:80 --network kit_default auth-service-dev

echo "✅ Auth Service reiniciado en http://localhost:8081"
echo "📝 Endpoints disponibles:"
echo "   - GET / - Información del API"
echo "   - POST /api/auth/signup - Registro con email o teléfono"
echo "   - POST /api/auth/signin - Inicio de sesión con email o teléfono"
echo "   - POST /api/auth/otp/send - Enviar código OTP al teléfono"
echo "   - POST /api/auth/otp/verify - Verificar código OTP"
echo "   - GET /api/auth/users - Listar usuarios (solo desarrollo)"
