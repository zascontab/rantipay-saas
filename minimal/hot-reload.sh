#!/bin/bash

PORT=9999

# Detener cualquier instancia previa de manera agresiva
sudo kill -9 $(sudo lsof -t -i:$PORT) 2>/dev/null || true

# Compilar
go build -o server server.go

# Iniciar
./server --port=$PORT &

echo "✅ Servidor iniciado en puerto $PORT (PID: $!)"
