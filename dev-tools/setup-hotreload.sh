#!/bin/bash

# Instalar Air para Hot Reload
go install github.com/cosmtrek/air@latest

# Crear configuración de Air para cada servicio
for service in user saas sys realtime order payment product; do
  mkdir -p ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/$service/tmp
  cat > ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/$service/.air.toml << AIRCONF
root = "."
tmp_dir = "tmp"

[build]
cmd = "go build -o ./tmp/main ./cmd/$service/main.go"
bin = "./tmp/main"
include_ext = ["go", "yaml", "yml"]
exclude_dir = ["tmp", "vendor"]
include_dir = []
exclude_file = []
delay = 1000 # ms
kill_delay = 500 # ms
stop_on_error = true
send_interrupt = true

[log]
time = true

[color]
main = "magenta"
watcher = "cyan"
build = "yellow"
runner = "green"

[misc]
clean_on_exit = true
AIRCONF
done

# Crear scripts para iniciar cada servicio con Hot Reload
cat > ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/dev-tools/run-user.sh << 'SVC_USER'
#!/bin/bash
cd ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/user
export DATA_DATABASE_SOURCE="root:youShouldChangeThis@tcp(localhost:3406)/user_db"
export ETCD_ADDRESS="localhost:3379"
export SERVER_HTTP_ADDR="0.0.0.0:8000"
export REDIS_ADDR="localhost:7379"
export REDIS_PASSWORD="youShouldChangeThis"
air
SVC_USER

cat > ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/dev-tools/run-saas.sh << 'SVC_SAAS'
#!/bin/bash
cd ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/saas
export DATA_DATABASE_SOURCE="root:youShouldChangeThis@tcp(localhost:3406)/saas_db"
export ETCD_ADDRESS="localhost:3379"
export SERVER_HTTP_ADDR="0.0.0.0:8001"
export REDIS_ADDR="localhost:7379"
export REDIS_PASSWORD="youShouldChangeThis"
air
SVC_SAAS

cat > ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/dev-tools/run-sys.sh << 'SVC_SYS'
#!/bin/bash
cd ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/sys
export DATA_DATABASE_SOURCE="root:youShouldChangeThis@tcp(localhost:3406)/sys_db"
export ETCD_ADDRESS="localhost:3379"
export SERVER_HTTP_ADDR="0.0.0.0:8002"
export REDIS_ADDR="localhost:7379"
export REDIS_PASSWORD="youShouldChangeThis"
air
SVC_SYS

# Hacer los scripts ejecutables
chmod +x ~/developer/projects/rantipay/wankarlab/rantipay-saas/kit/dev-tools/*.sh
