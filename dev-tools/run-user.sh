#!/bin/bash
cd ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/user
export DATA_DATABASE_SOURCE="root:youShouldChangeThis@tcp(localhost:3406)/user_db"
export ETCD_ADDRESS="localhost:3379"
export SERVER_HTTP_ADDR="0.0.0.0:8000"
export REDIS_ADDR="localhost:7379"
export REDIS_PASSWORD="youShouldChangeThis"
# En lugar de usar air, usaremos go run directamente
go run cmd/user/main.go -conf ../configs.dev/config.yaml
