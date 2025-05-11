# Rantipay SaaS: Guía de Implementación Detallada

Este documento proporciona instrucciones detalladas para implementar el ecosistema Rantipay SaaS basado en go-saas/kit. Incluye todos los pasos necesarios desde la clonación del repositorio hasta tener un sistema funcional con un API Gateway, frontend y servicios backend.

## Índice

1. [Requisitos Previos](#requisitos-previos)
2. [Estructura del Proyecto](#estructura-del-proyecto)
3. [Configuración Inicial](#configuración-inicial)
4. [Configuración de Contenedores](#configuración-de-contenedores)
   - [Configuración de NGINX Gateway](#configuración-de-nginx-gateway)
   - [Configuración del Frontend](#configuración-del-frontend)
   - [Configuración del Servicio User](#configuración-del-servicio-user)
5. [Docker Compose](#docker-compose)
6. [Script de Inicio](#script-de-inicio)
7. [Verificación y Pruebas](#verificación-y-pruebas)
8. [Solución de Problemas](#solución-de-problemas)
9. [Extensiones Futuras](#extensiones-futuras)
10. [Apéndices](#apéndices)

## Requisitos Previos

Antes de comenzar, asegúrate de tener instalados los siguientes componentes:

- **Docker**: v20.10.0 o superior
- **Docker Compose**: v2.0.0 o superior
- **Git**: 2.30.0 o superior
- **Go**: 1.18 o superior (opcional, solo si planeas compilar servicios localmente)

También es necesario tener disponibles los siguientes puertos:
- 8080: Frontend
- 81: API Gateway
- 8000: Servicio User
- 3406: MySQL
- 7379: Redis

## Estructura del Proyecto

La estructura del proyecto Rantipay SaaS es la siguiente:

```plaintext
rantipay_saas/
│
├── configs/                  # Configuraciones para los servicios
│   ├── apisix/               # Configs para APISIX (no utilizado actualmente)
│   └── ...                   # Otras configuraciones
│
├── kit/                      # Código fuente de go-saas/kit
│   ├── user/                 # Servicio de usuarios
│   ├── sys/                  # Servicios del sistema
│   ├── saas/                 # Servicios SaaS
│   └── ...                   # Otros servicios y componentes
│
├── kit-frontend/             # Frontend para el sistema
│   ├── docker/               # Configuraciones Docker para el frontend
│   │   └── nginx/            # Configuración de Nginx para el frontend
│   └── ...                   # Código fuente y otros archivos
│
├── nginx-gateway/            # Configuración NGINX como Gateway API
│   └── nginx.conf            # Archivo de configuración principal
│
├── simple-user/              # Servicio user simplificado
│   ├── Dockerfile            # Dockerfile para construir el servicio
│   ├── Dockerfile.debug      # Dockerfile para entorno de desarrollo
│   └── main.go               # Código fuente del servicio simplificado
│
├── docker-compose-nginx-gateway.yml  # Archivo principal para desplegar el sistema
├── start-nginx-gateway.sh            # Script para iniciar el stack completo
└── README.md                         # Documentación general
```

## Configuración Inicial

### 1. Clonar el Repositorio

Primero, clona el repositorio de Rantipay SaaS:

```bash
mkdir -p ~/developer/projects/rantipay/wankarlab
cd ~/developer/projects/rantipay/wankarlab
git clone https://github.com/tu-organización/rantipay_saas.git
cd rantipay_saas
```

### 2. Clonar go-saas/kit

A continuación, clona el repositorio de go-saas/kit:

```bash
git clone --recurse-submodules https://github.com/go-saas/kit.git
```

### 3. Clonar el Frontend

Clona el repositorio del frontend:

```bash
git clone https://github.com/go-saas/kit-frontend.git
```

## Configuración de Contenedores

### Configuración de NGINX Gateway

El NGINX Gateway actúa como punto de entrada para todas las solicitudes API, redireccionándolas al servicio apropiado.

1. Crea el directorio para la configuración de NGINX:

```bash
mkdir -p nginx-gateway
```

2. Crea el archivo de configuración de NGINX:

```bash
cat > nginx-gateway/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    
    sendfile        on;
    keepalive_timeout  65;

    server {
        listen 80;
        server_name localhost;
        
        # Proxy para el servicio de usuario
        location /v1/ {
            proxy_pass http://user:8000;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
        
        # Ruta de fallback
        location / {
            return 404 'API Gateway: Endpoint not found';
        }
    }
}
EOF
```

### Configuración del Frontend

El frontend es una aplicación React que necesita una configuración de NGINX para servir los archivos estáticos y redireccionar las llamadas API al gateway.

1. Crea el directorio para la configuración de NGINX del frontend:

```bash
mkdir -p kit-frontend/docker/nginx
```

2. Crea el archivo de configuración de NGINX para el frontend:

```bash
cat > kit-frontend/docker/nginx/default.conf << 'EOF'
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
        try_files $uri $uri/ /index.html;
    }

    # Redirigir llamadas API al gateway NGINX
    location /v1/ {
        proxy_pass http://nginx:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOF
```

### Configuración del Servicio User

El servicio User es un servicio Go simplificado que maneja las solicitudes de usuario. Vamos a configurar su Dockerfile.

1. Crea el directorio para el servicio User simplificado:

```bash
mkdir -p simple-user
```

2. Crea el archivo main.go para el servicio User simplificado:

```bash
cat > simple-user/main.go << 'EOF'
package main

import (
    "fmt"
    "log"
    "net/http"
)

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "Hello from simple user service")
    })

    http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintf(w, "OK")
    })

    log.Println("Starting server on :8000")
    log.Fatal(http.ListenAndServe(":8000", nil))
}
EOF
```

3. Crea el Dockerfile para el servicio User:

```bash
cat > simple-user/Dockerfile << 'EOF'
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
RUN go build -o app main.go

FROM debian:stable-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/app .
EXPOSE 8000
CMD ["/app/app"]
EOF
```

4. Crea una versión de desarrollo del Dockerfile:

```bash
cat > simple-user/Dockerfile.debug << 'EOF'
FROM golang:1.20 AS builder
WORKDIR /app
COPY . .
RUN go build -o app main.go

FROM debian:stable-slim
RUN apt-get update && apt-get install -y ca-certificates curl net-tools procps && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY --from=builder /app/app .
EXPOSE 8000
CMD ["/app/app"]
EOF
```

5. Construye la imagen de Docker para el servicio User:

```bash
cd simple-user
docker build -t simple-user:debug -f Dockerfile.debug .
cd ..
```

## Docker Compose

Ahora, vamos a crear el archivo Docker Compose que define todos los servicios necesarios para el sistema.

```bash
cat > docker-compose-nginx-gateway.yml << 'EOF'
services:
  # NGINX como API Gateway
  nginx:
    image: nginx:1.21
    ports:
      - "81:80"  # Usar puerto 81 para evitar conflictos
    volumes:
      - ./nginx-gateway/nginx.conf:/etc/nginx/nginx.conf:ro
    restart: unless-stopped
    networks:
      - app-network

  # Servicio User
  user:
    image: simple-user:debug
    ports:
      - "8000:8000"
    volumes:
      - ./configs:/data/conf
      - ./kit/quickstart/.assets:/app/.assets
    restart: unless-stopped
    networks:
      - app-network

  # Frontend
  web:
    image: goxiaoy/go-saas-kit-frontend:dev
    ports:
      - "8080:80"
    volumes:
      - ./kit-frontend/docker/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro
    restart: unless-stopped
    depends_on:
      - nginx
    networks:
      - app-network

  # Base de datos
  mysqld:
    image: mysql:8.0
    environment:
      - MYSQL_ROOT_PASSWORD=youShouldChangeThis
      - MYSQL_ROOT_HOST=%
    volumes:
      - mysql_data:/var/lib/mysql
    ports:
      - "3406:3306"
    restart: unless-stopped
    networks:
      - app-network

  # Cache
  redis:
    image: redis:6.0
    command: redis-server --requirepass youShouldChangeThis
    ports:
      - "7379:6379"
    restart: unless-stopped
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  mysql_data:
EOF
```

## Script de Inicio

Para facilitar el inicio del sistema, vamos a crear un script que automatice el proceso:

```bash
cat > start-nginx-gateway.sh << 'EOF'
#!/bin/bash

echo "Limpiando entorno anterior..."
docker compose -f docker-compose-nginx-gateway.yml down --remove-orphans

echo "Iniciando stack con NGINX como gateway..."
docker compose -f docker-compose-nginx-gateway.yml up -d

echo "Esperando a que los servicios estén disponibles..."
sleep 10

echo "Verificando estado del gateway..."
curl -s http://localhost:81/v1/health || echo "API no disponible"

echo
echo "Configuración completa:"
echo "- Frontend disponible en: http://localhost:8080"
echo "- API Gateway disponible en: http://localhost:81/v1/"
echo "- Servicio User disponible directamente en: http://localhost:8000"
echo
echo "Para probar el frontend, abre en tu navegador: http://localhost:8080"
EOF

chmod +x start-nginx-gateway.sh
```

## Verificación y Pruebas

Después de configurar todo, inicia el stack y realiza pruebas para asegurarte de que funciona correctamente:

```bash
./start-nginx-gateway.sh
```

### Pruebas Manuales

1. **Verificar el Frontend**:
   - Abre `http://localhost:8080` en tu navegador.
   - Deberías ver la interfaz de usuario de go-saas/kit.

2. **Verificar el API Gateway**:
   - Ejecuta `curl http://localhost:81/v1/health`
   - Deberías recibir `OK` como respuesta.

3. **Verificar el Servicio User Directamente**:
   - Ejecuta `curl http://localhost:8000`
   - Deberías recibir "Hello from simple user service" como respuesta.

## Solución de Problemas

### Problemas Comunes y Soluciones

1. **Contenedores que No Inician**:
   - Verifica los logs: `docker logs <container-id>`
   - Asegúrate de que los puertos no estén en uso: `netstat -tuln`
   - Comprueba la configuración de volúmenes y permisos.

2. **Problemas de Red entre Contenedores**:
   - Verifica que todos los contenedores estén en la misma red: `docker network inspect app-network`
   - Asegúrate de que los nombres de host en las configuraciones sean correctos.

3. **Errores 404 o 502 en el Frontend**:
   - Verifica que el gateway NGINX esté ejecutándose: `docker ps | grep nginx`
   - Comprueba la configuración de proxy en el frontend.
   - Asegúrate de que el servicio User esté respondiendo correctamente.

4. **Problemas con la Base de Datos**:
   - Verifica la conectividad: `docker exec -it rantipay_saas-mysqld-1 mysql -u root -p`
   - Comprueba los logs de MySQL: `docker logs rantipay_saas-mysqld-1`

## Extensiones Futuras

Siguiendo el plan de implementación original, puedes continuar con:

### 1. Integración del Servicio de Compañías

```bash
# Ejemplo: Crear un nuevo servicio basado en kit-layout
git clone https://github.com/go-saas/kit-layout companies-service
cd companies-service
# Personalizar el servicio según las necesidades
```

### 2. Integración del Servicio de Delivery

```bash
# Adaptar el servicio de delivery existente
# Implementar cambios para compatibilidad con el ecosistema go-saas/kit
```

### 3. Integración de OTP y WhatsApp Service

```bash
# Configurar NGINX Gateway para incluir rutas a estos servicios
# Ejemplo de adición a nginx.conf:
location /v1/otp/ {
    proxy_pass http://otp-service:8084;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

location /v1/whatsapp/ {
    proxy_pass http://whatsapp-service:8085;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

### 4. Integración de Servicios Financieros

```bash
# Adaptar los servicios de pago y liquidez
# Implementar integración con el sistema de facturación
```

### 5. Integración con Odoo Manager

```bash
# Configurar conexión con Odoo
# Implementar sincronización de datos
```

## Apéndices

### A. Comandos Docker Útiles

```bash
# Ver todos los contenedores
docker ps -a

# Ver logs de un contenedor
docker logs <container-id>

# Ejecutar un comando en un contenedor
docker exec -it <container-id> <command>

# Ver redes Docker
docker network ls

# Inspeccionar una red Docker
docker network inspect <network-name>
```

### B. Estructura de Directorios go-saas/kit

El proyecto go-saas/kit tiene la siguiente estructura:

```plaintext
kit/
├── auth/       # Servicio de autenticación
├── saas/       # Servicio de SaaS
├── tenant/     # Servicio de tenants
├── user/       # Servicio de usuarios
├── sys/        # Servicios del sistema
└── api/        # Definiciones de API
```

### C. Referencias y Recursos

- [go-saas/kit GitHub](https://github.com/go-saas/kit)
- [go-saas/kit-frontend GitHub](https://github.com/go-saas/kit-frontend)
- [Documentación de NGINX](https://nginx.org/en/docs/)
- [Documentación de Docker](https://docs.docker.com/)
- [Documentación de Docker Compose](https://docs.docker.com/compose/)

---

## Notas Finales

Esta guía detallada te permitirá reconstruir completamente el ecosistema Rantipay SaaS en caso de necesidad. Si tienes problemas o necesitas más información, consulta la documentación oficial de go-saas/kit o contáctanos para obtener soporte adicional.

Documento creado: Mayo 2025