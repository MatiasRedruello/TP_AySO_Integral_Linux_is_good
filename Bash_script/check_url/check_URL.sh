#!/bin/bash
clear

LISTA=$1
LOG_FILE="/var/log/status_url.log"

# Validar si el directorio no está creado
if [[ ! -d "/tmp/head-check" ]]; then
    # Crear la estructura de directorios si no existe
    mkdir -p /tmp/head-check/{error/{cliente,servidor},ok}
    echo "Estructura de directorios creada en /tmp/head-check"
else
    echo "El directorio /tmp/head-check ya existe"
fi

ANT_IFS=$IFS
IFS=$'\n'

#---- Dentro del bucle ----#
for LINEA in $(cat "$LISTA" | grep -v ^#)
do
  # Extraer dominio y URL de cada línea
  DOMINIO=$(echo "$LINEA" | awk '{print $1}')
  URL=$(echo "$LINEA" | awk '{print $2}')

  # Obtener el código de estado HTTP
  STATUS_CODE=$(curl -LI -o /dev/null -w '%{http_code}\n' -s "$URL")

  # Fecha y hora actual en formato yyyymmdd_hhmmss
  TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

  # Registrar en el archivo /var/log/status_url.log
  echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" | sudo tee -a "$LOG_FILE"

  # Clasificar la respuesta según el código de estado
  if [[ $STATUS_CODE -ge 200 && $STATUS_CODE -le 299 ]]; then
    LOG_CATEGORIAS="/tmp/head-check/ok/${DOMINIO}.log"
  elif [[ $STATUS_CODE -ge 400 && $STATUS_CODE -le 499 ]]; then
    LOG_CATEGORIAS="/tmp/head-check/error/cliente/${DOMINIO}.log"
  elif [[ $STATUS_CODE -ge 500 && $STATUS_CODE -le 599 ]]; then
    LOG_CATEGORIAS="/tmp/head-check/error/servidor/${DOMINIO}.log"
  else
    # Si el código no coincide con ninguno de los rangos
    LOG_CATEGORIAS="/tmp/head-check/otros/${DOMINIO}.log"
    mkdir -p "/tmp/head-check/otros"  # Crear esta carpeta si es necesaria
  fi

  # Guardar en el log específico según la categoría
  echo "$TIMESTAMP - Code:$STATUS_CODE - URL:$URL" | sudo tee -a "$LOG_CATEGORIAS"
done

#-------------------------#

IFS=$ANT_IFS

