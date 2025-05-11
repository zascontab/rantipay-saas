# Companies Service

Este servicio gestiona la información de compañías y empresas en la plataforma Rantipay SaaS.

## Endpoints

- GET /health: Verificación de estado del servicio
- GET /api/v1/companies: Obtiene la lista de compañías

## Compilación

```bash
cd companies-service
go build -o companies-service ./cmd/main.go
```

## Ejecución

```bash
./companies-service
```

## Docker

```bash
docker build -t companies-service .
docker run -p 8010:8010 companies-service
```
