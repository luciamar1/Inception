#!/bin/bash
set -e

echo "🔐 Generando certificados SSL..."
mkdir -p /etc/nginx/ssl

# Generar certificados si no existen
if [ ! -f /etc/nginx/ssl/lucia-ma.42.fr.crt ] || [ ! -f /etc/nginx/ssl/lucia-ma.42.fr.key ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/lucia-ma.42.fr.key \
        -out /etc/nginx/ssl/lucia-ma.42.fr.crt \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=42Madrid/CN=lucia-ma.42.fr"
    echo "✅ Certificados SSL generados"
fi

echo "🔍 Verificando configuración Nginx..."
nginx -t

echo "🎉 Iniciando Nginx..."
exec nginx -g "daemon off;"
