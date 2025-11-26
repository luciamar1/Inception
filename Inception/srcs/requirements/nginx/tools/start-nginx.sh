#!/bin/bash
set -e

# Generar certificados SSL si no existen
mkdir -p /etc/nginx/ssl
if [ ! -f /etc/nginx/ssl/lucia-ma.42.fr.crt ]; then
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/lucia-ma.42.fr.key \
        -out /etc/nginx/ssl/lucia-ma.42.fr.crt \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=42Madrid/CN=lucia-ma.42.fr"
fi

# Verificar configuración
nginx -t

# Iniciar nginx
exec nginx -g "daemon off;"
