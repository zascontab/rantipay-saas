#!/bin/bash

API_URL="http://localhost:8081"

# Función para mostrar resultados
show_response() {
  echo -e "\n🔍 Respuesta:"
  echo "$1" | jq -r '.'
  echo -e "\n------------------------------------"
}

# 1. Información del API
echo -e "\n🚀 Obteniendo información del API..."
RESPONSE=$(curl -s $API_URL/)
show_response "$RESPONSE"

# 2. Registro con email
echo -e "🚀 Registrando usuario con email..."
RESPONSE=$(curl -s -X POST $API_URL/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"secret123"}')
show_response "$RESPONSE"

# 3. Registro con teléfono
echo -e "🚀 Registrando usuario con teléfono..."
RESPONSE=$(curl -s -X POST $API_URL/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{"phone":"+123456789","password":"secret123"}')
show_response "$RESPONSE"

# 4. Enviar OTP
echo -e "🚀 Enviando código OTP..."
RESPONSE=$(curl -s -X POST $API_URL/api/auth/otp/send \
  -H "Content-Type: application/json" \
  -d '{"phone":"+123456789"}')
show_response "$RESPONSE"

# 5. Verificar OTP
echo -e "🚀 Verificando código OTP..."
RESPONSE=$(curl -s -X POST $API_URL/api/auth/otp/verify \
  -H "Content-Type: application/json" \
  -d '{"phone":"+123456789","code":"123456"}')
show_response "$RESPONSE"

# 6. Iniciar sesión con email
echo -e "🚀 Iniciando sesión con email..."
RESPONSE=$(curl -s -X POST $API_URL/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"secret123"}')
show_response "$RESPONSE"

# 7. Iniciar sesión con teléfono y OTP
echo -e "🚀 Iniciando sesión con teléfono y OTP..."
RESPONSE=$(curl -s -X POST $API_URL/api/auth/otp/send \
  -H "Content-Type: application/json" \
  -d '{"phone":"+123456789"}')
OTP_CODE=$(echo $RESPONSE | jq -r '.data.code')
RESPONSE=$(curl -s -X POST $API_URL/api/auth/signin \
  -H "Content-Type: application/json" \
  -d "{\"phone\":\"+123456789\",\"otp_code\":\"$OTP_CODE\"}")
show_response "$RESPONSE"

# 8. Listar usuarios
echo -e "🚀 Listando usuarios..."
RESPONSE=$(curl -s $API_URL/api/auth/users)
show_response "$RESPONSE"
