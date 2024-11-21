#!/bin/bash
clear

###############################
#
# Parametros:
#  - Lista de Usuarios a crear
#  - Usuario del cual se obtendra la clave
#
#  Tareas:
#  - Crear los usuarios segun la lista recibida en los grupos descriptos
#  - Los usuarios deberan de tener la misma clave que la del usuario pasado por parametro
#
###############################

LISTA=$1
USER=$2

CLAVE_USUARIO=$(sudo grep $USER /etc/shadow | awk -F ':' '{print $2}')


ANT_IFS=$IFS
IFS=$'\n'
for LINEA in `cat $LISTA |  grep -v ^#`
do
	USUARIO=$(echo  $LINEA |awk -F ',' '{print $1}')
	GRUPO=$(echo  $LINEA |awk -F ',' '{print $2}')
	DIRECTORIO=$(echo  $LINEA |awk -F ',' '{print $3}')
	
	sudo groupadd $GRUPO
	sudo useradd -m -d $DIRECTORIO -s /bin/bash -g $GRUPO -p "$CLAVE_USUARIO"  $USUARIO
done
IFS=$ANT_IFS

