# Guía de Implementación del Servicio de Usuario Completo

Esta guía detalla los pasos para reemplazar el servicio de usuario simplificado con el servicio completo de usuario de go-saas/kit.

## Archivos Generados

1. **Dockerfile para el servicio de usuario completo**
   - `user-dockerfile`
   
2. **Script para compilar el servicio de usuario**
   - `build-user-service.sh`
   
3. **Configuración para el servicio de usuario**
   - `user-config.yaml` (se copiará a `configs/user/config.yaml`)
   
4. **Script para actualizar el docker-compose**
   - `update-docker-compose.sh`
   
5. **Script para iniciar el sistema con el servicio completo**
   - `start-full-user.sh`
   
6. **Script para verificar el servicio de usuario completo**
   - `verify-full-user.sh`

## Instrucciones Paso a Paso

### 1. Preparación del Entorno

Asegúrate de estar en el directorio raíz del proyecto (`rantipay_saas`):

```bash
cd ~/developer/projects/rantipay/wankarlab/rantipay_saas
```

### 2. Guardar los archivos generados

Crea los archivos en las ubicaciones correctas usando los scripts proporcionados:

```bash
# Crear Dockerfile para el servicio de usuario
cat > user-dockerfile << 'EOF'
# Contenido del archivo user-dockerfile
EOF

# Crear script para compilar el servicio
cat > build-user-service.sh << 'EOF'
# Contenido del archivo build-user-service.sh
EOF
chmod +x build-user-service.sh

# Crear configuración del servicio
cat > user-config.yaml << 'EOF'
# Contenido del archivo user-config.yaml
EOF

# Crear script para actualizar docker-compose
cat > update-docker-compose.sh << 'EOF'
# Contenido del archivo update-docker-compose.sh
EOF
chmod +x update-docker-compose.sh

# Crear script para iniciar el sistema
cat > start-full-user.sh << 'EOF'
# Contenido del archivo start-full-user.sh
EOF
chmod +x start-full-user.sh

# Crear script para verificar el servicio
cat > verify-full-user.sh << 'EOF'
# Contenido del archivo verify-full-user.sh
EOF
chmod +x verify-full-user.sh
```

### 3. Compilar y Construir

Ejecuta el script para compilar el servicio de usuario y construir la imagen Docker:

```bash
./build-user-service.sh
```

Este script:
- Compila el servicio de usuario desde el código fuente en `kit/user`
- Genera el binario en `kit/user/bin/user`
- Construye la imagen Docker `go-saas-kit-user:latest`

### 4. Actualizar el Docker Compose

Ejecuta el script para actualizar el archivo docker-compose y configurar el servicio de usuario:

```bash
./update-docker-compose.sh
```

Este script:
- Crea un nuevo archivo `docker-compose-full-user.yml`
- Configura el servicio para usar la imagen `go-saas-kit-user:latest`
- Copia la configuración necesaria a `configs/user/config.yaml`

### 5. Iniciar el Sistema

Inicia el sistema con el servicio completo de usuario:

```bash
./start-full-user.sh
```

Este script:
- Detiene cualquier instancia previa
- Inicia los servicios de infraestructura (MySQL, Redis, ETCD)
- Inicializa la base de datos y ETCD
- Inicia el servicio de usuario y los demás servicios
- Verifica el estado de los servicios

### 6. Verificar la Implementación

Verifica que el servicio de usuario completo esté funcionando correctamente:

```bash
./verify-full-user.sh
```

Este script:
- Comprueba que el contenedor de usuario esté ejecutándose
- Verifica los endpoints principales (health, login, menus, websocket)
- Comprueba el acceso a través del API Gateway
- Verifica que el frontend esté disponible

### 7. Acceder al Sistema

Si todo se ha configurado correctamente, puedes acceder al sistema:

- **Frontend**: [http://localhost:8080](http://localhost:8080)
- **API Gateway**: [http://localhost:81](http://localhost:81)
- **Servicio de Usuario**: [http://localhost:8000](http://localhost:8000)

Credenciales de inicio de sesión:
- **Usuario**: admin@rantipay.com
- **Contraseña**: Admin123!

## Resolución de Problemas

### El contenedor del servicio de usuario no inicia

Verifica los logs del contenedor:

```bash
docker logs rantipay_saas-user-1
```

Posibles soluciones:
- Asegúrate de que la base de datos está inicializada: `./init-database.sh`
- Verifica que la configuración en `configs/user/config.yaml` es correcta
- Comprueba que ETCD está correctamente configurado: `./init-etcd.sh`

### El frontend no muestra los menús

Verifica que el endpoint de menús está funcionando:

```bash
# Obtener token (necesitas jq instalado)
TOKEN=$(curl -s -X POST -H "Content-Type: application/json" -d '{"username":"admin@rantipay.com","password":"Admin123!"}' http://localhost:8000/v1/auth/login | jq -r '.data.access_token')

# Verificar endpoint de menús
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:81/v1/sys/menus/available
```

Posibles soluciones:
- Actualiza la configuración de NGINX para asegurar que el endpoint de menús está correctamente direccionado
- Verifica que el servicio de usuario responde correctamente al endpoint

### Problemas con WebSocket

El endpoint WebSocket es crucial para la funcionalidad en tiempo real:

```bash
# Verificar configuración WebSocket
curl -v http://localhost:81/v1/realtime/connect/ws
```

Posibles soluciones:
- Asegúrate de que NGINX está configurado para manejar conexiones WebSocket
- Verifica que el servicio de usuario tiene configurado correctamente el módulo de tiempo real

## Volver al Servicio Simplificado

Si necesitas volver al servicio simplificado, puedes usar:

```bash
docker compose -f docker-compose-hybrid-plus.yml down
docker compose -f docker-compose-hybrid-plus.yml up -d
```

## Conclusión

Has implementado exitosamente el servicio completo de usuario de go-saas/kit. Este servicio proporciona todas las funcionalidades necesarias para la autenticación, gestión de usuarios, y comunicación con otros servicios del ecosistema.