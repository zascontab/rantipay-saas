#!/bin/bash

echo "Probando configuración del servicio User..."
./bin/user -conf configs/user

if [ $? -eq 0 ]; then
  echo "Configuración de User correcta!"
else
  echo "Error en la configuración de User."
  exit 1
fi

echo "Probando configuración del servicio SaaS..."
./bin/saas -conf configs/saas

if [ $? -eq 0 ]; then
  echo "Configuración de SaaS correcta!"
else
  echo "Error en la configuración de SaaS."
  exit 1
fi

echo "Probando configuración del servicio Sys..."
./bin/sys -conf configs/sys

if [ $? -eq 0 ]; then
  echo "Configuración de Sys correcta!"
else
  echo "Error en la configuración de Sys."
  exit 1
fi

echo "Todas las configuraciones son correctas!"