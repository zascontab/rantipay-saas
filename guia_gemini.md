# GoSaaS Kit: Guía Detallada de Configuración del Entorno de Desarrollo Local

Esta guía te llevará paso a paso a través de la configuración de un entorno de desarrollo local para GoSaaS Kit. Se enfoca en el uso de versiones específicas de herramientas para asegurar la compatibilidad y sigue las prácticas estándar de desarrollo en Go, complementado con la estructura y herramientas del repositorio `go-saas/kit`.

**Fecha de Guía:** 2025-05-19
**Usuario:** zascontab

## Índice

1.  [Prerrequisitos e Instalación de Herramientas](#1-prerrequisitos-e-instalación-de-herramientas)
    *   [Git](#git)
    *   [Go (Golang)](#go-golang)
    *   [Protocol Buffers (protoc)](#protocol-buffers-protoc)
    *   [Herramientas Go para gRPC y Protobuf](#herramientas-go-para-grpc-y-protobuf)
    *   [Buf](#buf)
    *   [Docker y Docker Compose](#docker-y-docker-compose)
    *   [Make y Herramientas de Compilación](#make-y-herramientas-de-compilación)
    *   [Curl](#curl)
2.  [Configuración del Proyecto GoSaaS Kit](#2-configuración-del-proyecto-gosaas-kit)
    *   [Clonación del Repositorio](#clonación-del-repositorio)
    *   [Inicialización del Proyecto (Makefile)](#inicialización-del-proyecto-makefile)
    *   [Configuración de Buf y Dependencias Proto](#configuración-de-buf-y-dependencias-proto)
    *   [Generación de Código a partir de Archivos Proto](#generación-de-código-a-partir-de-archivos-proto)
    *   [Dependencias de Módulos Go](#dependencias-de-módulos-go)
3.  [Configuración y Ejecución con Docker Compose](#3-configuración-y-ejecución-con-docker-compose)
    *   [Entendiendo el `docker-compose.yml`](#entendiendo-el-docker-composeyml)
    *   [Variables de Entorno para Docker](#variables-de-entorno-para-docker)
    *   [Levantando el Entorno](#levantando-el-entorno)
    *   [Verificación de Servicios Docker](#verificación-de-servicios-docker)
4.  [Desarrollo y Modificación de Código](#4-desarrollo-y-modificación-de-código)
    *   [Estructura de Módulos Go](#estructura-de-módulos-go)
    *   [Modificar Código Go](#modificar-código-go)
    *   [Reflejar Cambios en Docker](#reflejar-cambios-en-docker)
    *   [Modificar Archivos `.proto`](#modificar-archivos-proto)
5.  [Ejecución de Servicios Individuales (Opcional)](#5-ejecución-de-servicios-individuales-opcional)
6.  [Compilación de Binarios](#6-compilación-de-binarios)
7.  [Verificación del Entorno Funcional](#7-verificación-del-entorno-funcional)
8.  [Resolución de Problemas Comunes](#8-resolución-de-problemas-comunes)

---

## 1. Prerrequisitos e Instalación de Herramientas

Asegúrate de que las siguientes herramientas estén instaladas con las versiones especificadas. Los comandos son para Ubuntu/macOS.

### Git

*   **Propósito:** Control de versiones.
*   **Instalación:**
    *   Ubuntu: `sudo apt update && sudo apt install -y git`
    *   macOS (con Homebrew): `brew install git`
*   **Verificación:**
    ```bash
    git --version
    ```
    Deberías ver una versión reciente (e.g., `git version 2.3x.x` o superior).

### Go (Golang)

*   **Propósito:** Lenguaje de programación principal. El `go.mod` de `go-saas/kit` especifica `go 1.20`. Se recomienda usar **Go 1.21.5+**.
*   **Instalación (Go 1.21.5):**
    *   **Eliminar instalación previa (si existe):**
        ```bash
        sudo rm -rf /usr/local/go
        ```
    *   **Descargar y extraer:**
        ```bash
        wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
        sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
        rm go1.21.5.linux-amd64.tar.gz
        ```
    *   **Configurar PATH:** Añade esto a tu `~/.bashrc` o `~/.zshrc`:
        ```bash
        export PATH=$PATH:/usr/local/go/bin
        export GOPATH=$HOME/go 
        export PATH=$PATH:$GOPATH/bin 
        ```
        Luego, ejecuta `source ~/.bashrc` o `source ~/.zshrc`.
*   **Verificación:**
    ```bash
    go version
    ```
    Debería mostrar: `go version go1.21.5 linux/amd64` (o la arquitectura de tu sistema).
    ```bash
    go env GOROOT GOPATH
    ```
    Debería mostrar las rutas configuradas.

### Protocol Buffers (protoc)

*   **Propósito:** Compilador de Protocol Buffers. Se usará **protoc v25.1**.
*   **Instalación (protoc v25.1):**
    ```bash
    PB_REL="25.1"
    PB_ARCH="linux-x86_64" # Cambiar a osx-x86_64 para macOS Intel, osx-aarch_64 para macOS Apple Silicon
    wget "https://github.com/protocolbuffers/protobuf/releases/download/v${PB_REL}/protoc-${PB_REL}-${PB_ARCH}.zip"
    unzip "protoc-${PB_REL}-${PB_ARCH}.zip" -d "$HOME/.local"
    rm "protoc-${PB_REL}-${PB_ARCH}.zip"
    ```
    *   **Añadir al PATH (si `$HOME/.local/bin` no está ya):** Añade a tu `~/.bashrc` o `~/.zshrc`:
        ```bash
        export PATH=$HOME/.local/bin:$PATH
        ```
        Luego, `source ~/.bashrc` o `source ~/.zshrc`.
    *   **Mover includes (Opcional, pero recomendado para evitar problemas):**
        ```bash
        sudo cp -r $HOME/.local/include/* /usr/local/include/
        ```
        Si no tienes permisos sudo o prefieres no hacerlo, asegúrate de que los compiladores puedan encontrar estos includes.
*   **Verificación:**
    ```bash
    protoc --version
    ```
    Debería mostrar: `libprotoc 25.1`.

### Herramientas Go para gRPC y Protobuf

*   **Propósito:** Generadores de código Go para Protobuf y gRPC, incluyendo herramientas específicas de Kratos y `go-saas/kit`.
*   **Instalación:**
    ```bash
    # protoc-gen-go (Google's Go bindings for protocol buffers)
    go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.31.0

    # protoc-gen-go-grpc (gRPC Go plugin)
    go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0

    # Kratos CLI (go-saas/kit usa Kratos v2.7.0, instala una CLI compatible)
    go install github.com/go-kratos/kratos/cmd/kratos/v2@v2.7.0

    # protoc-gen-go-http (Kratos HTTP plugin)
    go install github.com/go-kratos/kratos/cmd/protoc-gen-go-http/v2@v2.7.0 # Usa la misma versión que el CLI de Kratos

    # protoc-gen-validate (Validación de mensajes Protobuf)
    go install github.com/envoyproxy/protoc-gen-validate@v1.0.2

    # Herramientas internas de go-saas/kit (usa los commits exactos de tu script)
    # Estas rutas asumen que `go-saas/kit` no está aún en tu GOPATH/src o que quieres la versión exacta
    # Si ya clonaste `go-saas/kit`, puedes usar `go install ./cmd/protoc-gen-go-grpc-proxy` desde la raíz del repo
    # pero para una instalación global inicial, los siguientes comandos son más explícitos:
    KIT_COMMIT="c2ded75bd3ee9f1229e50d7141966ecbde39a84f" # Commit de tu script
    go install github.com/go-saas/kit/cmd/protoc-gen-go-grpc-proxy@${KIT_COMMIT}
    go install github.com/go-saas/kit/cmd/protoc-gen-go-errors-i18n/v2@${KIT_COMMIT}
    ```
*   **Verificación:**
    Asegúrate de que `$GOPATH/bin` esté en tu `PATH`.
    ```bash
    which protoc-gen-go
    which protoc-gen-go-grpc
    which kratos
    which protoc-gen-go-http
    which protoc-gen-validate
    which protoc-gen-go-grpc-proxy
    which protoc-gen-go-errors-i18n
    ```
    Cada comando debería mostrar la ruta al binario instalado.
    ```bash
    protoc-gen-go --version # Debería ser v1.31.0
    protoc-gen-go-grpc --version # Debería ser v1.3.0
    kratos --version # Debería ser v2.7.0
    ```

### Buf

*   **Propósito:** Herramienta para trabajar con Protocol Buffers, usada por `go-saas/kit`. Se usará **Buf v1.27.1**.
*   **Instalación (Buf v1.27.1):**
    ```bash
    go install github.com/bufbuild/buf/cmd/buf@v1.27.1
    go install github.com/bufbuild/buf/cmd/protoc-gen-buf-breaking@v1.27.1
    go install github.com/bufbuild/buf/cmd/protoc-gen-buf-lint@v1.27.1
    ```
*   **Verificación:**
    ```bash
    buf --version
    ```
    Debería mostrar: `1.27.1`.

### Docker y Docker Compose

*   **Propósito:** Para ejecutar la aplicación y sus dependencias (bases de datos, Redis, etc.) en contenedores.
*   **Instalación:** Sigue la guía oficial en [docs.docker.com](https://docs.docker.com/get-docker/). Asegúrate de instalar Docker Compose también (generalmente viene con Docker Desktop, o como un plugin `docker compose`).
*   **Verificación:**
    ```bash
    docker --version
    docker compose version # o `docker-compose --version` para versiones más antiguas
    ```
    Deberías ver versiones recientes.

### Make y Herramientas de Compilación

*   **Propósito:** `go-saas/kit` usa un `Makefile` para automatizar tareas.
*   **Instalación:**
    *   Ubuntu: `sudo apt install -y build-essential make`
    *   macOS: Las herramientas de línea de comandos de Xcode suelen incluir `make`. Ejecuta `xcode-select --install` si es necesario.
*   **Verificación:**
    ```bash
    make --version
    ```

### Curl

*   **Propósito:** Para realizar peticiones HTTP y probar endpoints.
*   **Instalación:**
    *   Ubuntu: `sudo apt install -y curl`
    *   macOS: Generalmente preinstalado. `brew install curl` si es necesario.
*   **Verificación:**
    ```bash
    curl --version
    ```

---

## 2. Configuración del Proyecto GoSaaS Kit

### Clonación del Repositorio

1.  Crea un directorio para tus proyectos (si no lo tienes) y clona el repositorio:
    ```bash
    mkdir -p ~/developer/projects/go-saas # Ajusta la ruta según tu preferencia
    cd ~/developer/projects/go-saas
    git clone https://github.com/go-saas/kit.git
    cd kit
    ```
    **Verificación:** `ls -la` debería mostrar el contenido del repositorio.

### Inicialización del Proyecto (Makefile)

El `Makefile` de `go-saas/kit` tiene un target `init` que configura enlaces simbólicos para `buf`.

1.  Ejecuta el comando de inicialización desde la raíz del repositorio `kit`:
    ```bash
    make init
    ```
    **Verificación:**
    ```bash
    ls -la buf/
    ```
    Deberías ver enlaces simbólicos como `api -> ../api` y `pkg -> ../pkg`.

### Configuración de Buf y Dependencias Proto

El proyecto utiliza `buf` para gestionar las dependencias de Protocol Buffers.

1.  **Crear/Verificar `buf.yaml`:**
    El repositorio `go-saas/kit` ya incluye un `buf.yaml`. Su contenido es algo así:
    ```yaml
    version: v1
    name: buf.build/goxy/kit # El nombre puede variar o estar ausente
    deps:
      - buf.build/beta/googleapis
      - buf.build/gogo/protobuf
      - buf.build/envoyproxy/protoc-gen-validate
      # ... otras dependencias de buf.build
    build:
      roots:
        - api
        - pkg
        # ... otros directorios raíz con archivos .proto
    lint:
      use:
        - DEFAULT
      except:
        - FIELD_LOWER_SNAKE_CASE # Ejemplo de excepciones
    breaking:
      use:
        - FILE
    ```
    **Nota:** La dependencia `buf.build/goxy/go-saas-kit` que mencionaste en tu script podría ser una forma en que el proyecto consume sus propias APIs publicadas o una dependencia externa. Si es para consumir sus propias APIs como un módulo, asegúrate que `buf.yaml` esté correctamente configurado. El `buf.yaml` actual en `go-saas/kit` no lista `buf.build/goxy/go-saas-kit`.

2.  **Actualizar Dependencias de Buf:**
    Desde la raíz del repositorio `kit`:
    ```bash
    buf mod update
    ```
    **Verificación:** Un directorio `.buf` debería ser creado o actualizado en la raíz del proyecto, conteniendo las dependencias descargadas.

### Generación de Código a partir de Archivos Proto

El `Makefile` también tiene un target `api` para generar el código Go desde los archivos `.proto` usando `buf`.

1.  Genera los archivos:
    ```bash
    make api
    ```
    Esto ejecutará `buf generate` según la configuración en `buf.gen.yaml`.
    **Verificación:**
    *   No deberían aparecer errores durante la ejecución.
    *   Busca archivos `.pb.go`, `.pb.validate.go`, `.pb.http.go`, etc., generados o actualizados dentro de los directorios `api/` y `pkg/` (o donde estén tus protos y sus correspondientes salidas de Go).
        ```bash
        find api pkg -name "*.pb.go" | head -n 5
        ```

### Dependencias de Módulos Go

Una vez generado el código Go a partir de los protos (si alguno era nuevo o modificado), actualiza las dependencias del módulo Go principal.

1.  Ejecuta desde la raíz del repositorio `kit`:
    ```bash
    go mod tidy
    go mod download # Opcional, tidy usualmente lo hace.
    ```
    **Verificación:** El archivo `go.mod` y `go.sum` se actualizarán. No deberían haber errores.

---

## 3. Configuración y Ejecución con Docker Compose

El repositorio `go-saas/kit` incluye un archivo `docker-compose.yml` para orquestar todos los servicios necesarios.

### Entendiendo el `docker-compose.yml`

Este archivo define servicios como:
*   `web`: Placeholder para un frontend.
*   `api_docs`: Para la documentación Swagger/OpenAPI.
*   `apisix`: API Gateway.
*   `apisix-dashboard`: Dashboard para APISIX.
*   `hydra` & `hydra-migrate`: Servidor OAuth2/OpenID Connect y sus migraciones.
*   `mysqld`: Base de datos MySQL (versión 8.0).
*   `redis`: Almacén en memoria (versión 6.0).
*   `etcd`: Almacén clave-valor distribuido.
*   `dtm`: Gestor de transacciones distribuidas.

**Importante para desarrollo local de GoSaaS Kit:** El `docker-compose.yml` actual está configurado para usar imágenes pre-construidas para muchos componentes (`image: ${DOCKER_REGISTRY}go-saas-kit-xxx`). Para desarrollar los servicios Go que forman parte de `go-saas/kit` (si no son consumidos como imágenes externas), necesitarás:
1.  Asegurarte de que haya servicios definidos en `docker-compose.yml` para tus aplicaciones Go.
2.  Estos servicios deben usar una directiva `build:` que apunte al `Dockerfile` de cada aplicación Go dentro del repositorio.
3.  Montar volúmenes para tu código fuente Go para permitir la recarga en caliente o reconstrucciones rápidas.

Si `go-saas/kit` es en sí mismo un conjunto de microservicios Go que se construyen desde este repo, el `docker-compose.yml` necesitaría ser adaptado. Por ejemplo, para un servicio `mi-servicio-go`:

```yaml
# En docker-compose.yml
services:
  # ... otros servicios ...

  mi-servicio-go:
    build:
      context: ./cmd/mi-servicio-go # Ruta al directorio del servicio con su Dockerfile
      dockerfile: Dockerfile
    volumes:
      - ./cmd/mi-servicio-go:/app # Monta el código fuente
      # Podrías necesitar montar también el directorio pkg y api si son dependencias locales
      - ./pkg:/app/pkg
      - ./api:/app/api
    ports:
      - "8080:8080" # Expone el puerto del servicio
    environment:
      # Variables de entorno necesarias para conectarse a DB, Redis, etc.
      # Estas deben usar los nombres de servicio de Docker (e.g., mysqld, redis)
      - DB_HOST=mysqld
      - DB_PORT=3306
      - REDIS_ADDR=redis:6379
    depends_on:
      - mysqld
      - redis
    restart: unless-stopped # o 'on-failure' durante el desarrollo
```
Y un `Dockerfile` simple en `./cmd/mi-servicio-go/Dockerfile`:
```Dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copia go.mod y go.sum y descarga dependencias primero para cacheo
COPY go.mod go.sum ./
RUN go mod download

# Copia el resto del código fuente del proyecto (incluyendo pkg, api, etc.)
# Asumiendo que los volúmenes los harán disponibles o necesitas copiarlos explícitamente
COPY . .

# Compila tu aplicación específica
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server ./cmd/mi-servicio-go

FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/server /app/server
# Copia archivos de configuración si los hay
# COPY ./cmd/mi-servicio-go/configs /app/configs

EXPOSE 8080
CMD ["/app/server"] # O el comando para iniciar tu servicio
```

### Variables de Entorno para Docker

El `docker-compose.yml` ya define muchas variables de entorno para los servicios. Revisa el archivo para contraseñas por defecto (e.g., `MYSQL_ROOT_PASSWORD=youShouldChangeThis`, `requirepass youShouldChangeThis` para Redis). Estas son usadas *dentro* de la red Docker.

### Levantando el Entorno

Desde la raíz del repositorio `kit`:
```bash
docker compose up -d
```
Si es la primera vez o hay cambios en los Dockerfiles (con directivas `build:`), Docker construirá las imágenes necesarias.

### Verificación de Servicios Docker

1.  **Listar contenedores activos:**
    ```bash
    docker ps
    ```
    Deberías ver todos los servicios del `docker-compose.yml` corriendo (estado `Up`).
2.  **Ver logs de un servicio:**
    ```bash
    docker compose logs -f apisix # Por ejemplo, para ver los logs de apisix
    docker compose logs -f mysqld
    docker compose logs -f mi-servicio-go # Si añadiste tu servicio Go
    ```

---

## 4. Desarrollo y Modificación de Código

### Estructura de Módulos Go

Explora los directorios `cmd/`, `internal/`, `pkg/`, `api/` para entender la organización del código Go y los servicios.

### Modificar Código Go

1.  Abre el proyecto en tu IDE preferido (e.g., VS Code con la extensión de Go).
2.  Localiza el archivo Go que deseas modificar (e.g., un handler HTTP, lógica de negocio).
3.  Realiza tus cambios.

### Reflejar Cambios en Docker

Si has configurado tu servicio Go en `docker-compose.yml` con un contexto de `build` y montado el código fuente como volumen:
*   **Para algunos frameworks Go con recarga en caliente (e.g., usando Air, Fresh):** Los cambios podrían reflejarse automáticamente.
*   **Sin recarga en caliente:** Necesitarás reconstruir y reiniciar el servicio específico:
    ```bash
    docker compose build mi-servicio-go 
    docker compose up -d --no-deps mi-servicio-go 
    ```
    La opción `--no-deps` evita reiniciar las dependencias si no han cambiado.

### Modificar Archivos `.proto`

Si modificas archivos `.proto` (e.g., en `api/` o `pkg/`):

1.  Realiza los cambios en el archivo `.proto`.
2.  **Regenera el código Go:**
    ```bash
    make api
    ```
3.  **Actualiza dependencias Go (si es necesario):**
    ```bash
    go mod tidy
    ```
4.  **Reconstruye la imagen Docker de tu servicio Go afectado:**
    ```bash
    docker compose build mi-servicio-go
    docker compose up -d --no-deps mi-servicio-go
    ```

---

## 5. Ejecución de Servicios Individuales (Opcional)

Para una depuración más rápida de un servicio Go específico, puedes ejecutarlo directamente en tu máquina local (fuera de Docker), siempre que sus dependencias (MySQL, Redis) estén accesibles.

1.  **Asegúrate de que las dependencias estén corriendo:** Puedes usar las instancias levantadas por `docker-compose up -d`.
2.  **Configura Variables de Entorno LOCALES:**
    Tu aplicación Go necesitará conectarse a los puertos *mapeados* de Docker. Desde el `docker-compose.yml` de `go-saas/kit`:
    *   MySQL: `localhost:3406`
    *   Redis: `localhost:7379`
    *   etcd: `localhost:3379`
    ```bash
    export DB_HOST=127.0.0.1
    export DB_PORT=3406
    export DB_USER=root # O el usuario que tu app use
    export DB_PASSWORD=youShouldChangeThis # La contraseña de MySQL
    export DB_NAME=kit # O la base de datos específica
    export REDIS_ADDR=127.0.0.1:7379
    export REDIS_PASSWORD=youShouldChangeThis
    # ... otras variables que necesite tu servicio ...
    ```
3.  **Ejecuta el Servicio:**
    Navega al directorio `cmd/` de tu servicio (e.g., `cd cmd/mi-servicio-go`) y ejecuta:
    ```bash
    go run main.go # o el nombre de tu archivo principal
    ```

---

## 6. Compilación de Binarios

Para compilar un servicio Go en un binario ejecutable:

1.  Navega al directorio `cmd/` de tu servicio.
2.  Ejecuta:
    ```bash
    go build -o nombre_del_binario main.go
    # Ejemplo: go build -o mi_servicio_app main.go
    ```
    El binario `nombre_del_binario` se creará en el directorio actual.
    **Verificación:** `./nombre_del_binario --help` (si tu app usa flags) o simplemente `./nombre_del_binario` para ejecutarlo (asegúrate de tener las variables de entorno configuradas si lo ejecutas localmente).

---

## 7. Verificación del Entorno Funcional

1.  **Todos los contenedores Docker corriendo:** `docker ps` (todos en estado `Up`).
2.  **Conexión a MySQL:**
    Usa un cliente MySQL (e.g., `mysql-client`, DBeaver, DataGrip) para conectarte a `127.0.0.1:3406` con usuario `root` y contraseña `youShouldChangeThis`. Intenta listar bases de datos (`SHOW DATABASES;`).
3.  **Conexión a Redis:**
    ```bash
    redis-cli -h 127.0.0.1 -p 7379 -a youShouldChangeThis ping
    ```
    Debería responder `PONG`.
4.  **Probar Endpoints de API:**
    *   El `docker-compose.yml` expone APISIX en el puerto `80` (HTTP) y `443` (HTTPS) del host.
    *   Consulta la configuración de APISIX (en `quickstart/configs/apisix/`) o la documentación de la API para rutas válidas.
    *   Prueba un endpoint de health check o uno básico:
        ```bash
        curl http://localhost/ # Podría ser la UI o una ruta por defecto de APISIX
        # Si tienes un servicio Go 'users' ruteado por APISIX bajo /users-service/api/v1
        curl http://localhost/users-service/api/v1/health 
        ```
        Los endpoints exactos dependerán de cómo APISIX esté configurado para enrutar a tus servicios Go.

---

## 8. Resolución de Problemas Comunes

*   **"protoc-gen-X: program not found or is not executable"**:
    *   Verifica que `$GOPATH/bin` esté en tu `PATH`.
    *   Reinstala la herramienta específica: `go install ...`
*   **"buf: command not found"**:
    *   Verifica que `$GOPATH/bin` esté en tu `PATH`.
    *   Reinstala `buf`: `go install github.com/bufbuild/buf/cmd/buf@v1.27.1`
*   **Errores de `go mod tidy` / `go build`**:
    *   Asegúrate de que los archivos `.proto` se hayan generado correctamente (`make api`).
    *   `go clean -modcache` y luego `go mod tidy` de nuevo.
*   **Errores de conexión a DB/Redis desde la app Go (en Docker):**
    *   Asegúrate de que los nombres de host en la configuración de tu app Go sean los nombres de servicio de Docker (e.g., `mysqld`, `redis`), no `localhost`.
    *   Verifica que los servicios `depends_on` estén correctamente configurados en `docker-compose.yml`.
*   **Puertos en conflicto (Port already allocated):**
    *   Detén el servicio que usa el puerto (`sudo lsof -i :<puerto>`) o cambia el mapeo de puertos en `docker-compose.yml` (e.g., cambiar `"80:9080"` a `"8088:9080"` si el puerto 80 está ocupado en tu host).
*   **Errores en `make api` o `buf generate`**:
    *   Revisa los mensajes de error de `buf`. Pueden indicar problemas de sintaxis en `.proto`, dependencias faltantes en `buf.yaml`, o problemas con los plugins generadores.
    *   Asegúrate de que todos los plugins (`protoc-gen-*`) estén instalados y en el `PATH`.

---

Esta guía minuciosa debería ayudarte a configurar tu entorno. ¡Mucha suerte con el desarrollo en GoSaaS Kit!