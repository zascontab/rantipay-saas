#!/bin/bash

# Compilar nueva imagen
docker build -t user-microserver .

# Reiniciar contenedor con puerto expuesto
docker stop user-microserver
docker rm user-microserver
docker run -d --name user-microserver -p 8080:80 --network kit_default user-microserver

echo "✅ Servidor reconstruido y reiniciado en http://localhost:8080"
