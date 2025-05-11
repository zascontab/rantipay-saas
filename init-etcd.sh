#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verificar si ETCD está en ejecución
echo -e "${YELLOW}Verificando estado de ETCD...${NC}"
if ! docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl endpoint health 2>/dev/null; then
    echo -e "${RED}Error: ETCD no está en ejecución${NC}"
    exit 1
fi

echo -e "${YELLOW}Registrando servicios en ETCD...${NC}"

# Registrar servicio user
echo -e "${YELLOW}Registrando servicio user...${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl put "/services/user/1" '{"id":"1","name":"user","address":"user","port":9000,"metadata":{"kind":"grpc"}}'

# Registrar servicio saas
echo -e "${YELLOW}Registrando servicio saas...${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl put "/services/saas/1" '{"id":"1","name":"saas","address":"saas","port":9000,"metadata":{"kind":"grpc"}}'

# Registrar servicio sys
echo -e "${YELLOW}Registrando servicio sys...${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl put "/services/sys/1" '{"id":"1","name":"sys","address":"sys","port":9000,"metadata":{"kind":"grpc"}}'

echo -e "${GREEN}Servicios registrados correctamente en ETCD${NC}"

# Verificar registros
echo -e "${YELLOW}Verificando registros en ETCD...${NC}"
echo -e "${YELLOW}1. Servicio user:${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl get "/services/user/1" --print-value-only

echo -e "${YELLOW}2. Servicio saas:${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl get "/services/saas/1" --print-value-only

echo -e "${YELLOW}3. Servicio sys:${NC}"
docker exec $(docker ps -q -f name=rantipay_saas-etcd) etcdctl get "/services/sys/1" --print-value-only

echo -e "${GREEN}ETCD ha sido inicializado correctamente${NC}"