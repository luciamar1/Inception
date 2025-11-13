#!/bin/bash
set -e

echo "=== INICIANDO NGINX ==="

# Crear directorios si no existen
mkdir -p /etc/nginx/ssl
mkdir -p /var/run/nginx

# Generar certificados SSL si no existen
if [ ! -f /etc/nginx/ssl/lucia-ma.42.fr.crt ] || [ ! -f /etc/nginx/ssl/lucia-ma.42.fr.key ]; then
    echo "Generando certificados SSL..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/lucia-ma.42.fr.key \
        -out /etc/nginx/ssl/lucia-ma.42.fr.crt \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=42Madrid/CN=lucia-ma.42.fr"
    echo "✓ Certificados SSL generados"
else
    echo "✓ Certificados SSL ya existen"
fi

# Verificar configuración
echo "Verificando configuración de Nginx..."
nginx -t

echo "=== INICIANDO SERVICIO NGINX ==="
exec nginx -g "daemon off;"
