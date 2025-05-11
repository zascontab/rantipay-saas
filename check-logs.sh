#!/bin/bash

# Colores para mensajes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==============================================${NC}"
echo -e "${YELLOW}   Verificando logs de los servicios con problemas   ${NC}"
echo -e "${YELLOW}==============================================${NC}"
echo ""

echo -e "${YELLOW}Log del servicio User:${NC}"
docker logs rantipay_saas-user-1
echo ""
echo -e "${GREEN}---------------------------------------------${NC}"
echo ""

echo -e "${YELLOW}Log del servicio NGINX:${NC}"
docker logs rantipay_saas-nginx-1
echo ""
echo -e "${GREEN}---------------------------------------------${NC}"
echo ""

echo -e "${YELLOW}Verificando configuración del servicio User:${NC}"
ls -la configs/user/
cat configs/user/config.yaml
echo ""
echo -e "${GREEN}---------------------------------------------${NC}"
echo ""

echo -e "${YELLOW}Verificando configuración de NGINX:${NC}"
ls -la nginx-gateway/
cat nginx-gateway/nginx-full.conf
echo ""
echo -e "${GREEN}---------------------------------------------${NC}"
echo ""

echo -e "${YELLOW}Para solucionar el problema, considera:${NC}"
echo -e "1. Verificar que la configuración del servicio User es correcta"
echo -e "2. Asegurarte de que el directorio de configuración está montado correctamente"
echo -e "3. Revisar que los servicios están configurados correctamente en ETCD"
echo -e "4. Asegurarte de que NGINX está configurado para acceder al servicio User"
