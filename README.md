# Rantipay SaaS Platform - Entorno 100% Local

Este repositorio contiene una implementación completamente local de Rantipay SaaS basada en go-saas/kit. Todas las imágenes se construyen localmente sin depender de registros externos.

## Requisitos

- Docker y Docker Compose
- Go 1.18 o superior
- Make

## Estructura del proyecto

- `kit/`: Código fuente de go-saas/kit
- `kit-frontend/`: Frontend React
- `docker-compose-local.yml`: Configuración para despliegue con imágenes locales
- `global.env`: Variables de entorno
- `build-simplified.sh`: Script para construcción simplificada de imágenes

## Construcción de imágenes locales

### Método 1: Usando Dockerfiles originales
```bash
cd kit
docker build -t go-saas-kit-user:local -f user/Dockerfile .
docker build -t go-saas-kit-saas:local -f saas/Dockerfile .
docker build -t go-saas-kit-sys:local -f sys/Dockerfile .

no hay como subir

# Desplegar todo el sistema
docker compose -f docker-compose-local.yml --env-file global.env up -d

# Despliegue por fases
docker compose -f docker-compose-local.yml --env-file global.env up -d etcd mysqld redis
docker compose -f docker-compose-local.yml --env-file global.env up -d kafka kafka-ui
docker compose -f docker-compose-local.yml --env-file global.env up -d user saas sys
docker compose -f docker-compose-local.yml --env-file global.env up -d apisix apisix-dashboard web