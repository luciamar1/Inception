#!/bin/bash

echo "=== Generando certificados SSL ==="

# Crear directorio SSL si no existe
mkdir -p /etc/nginx/ssl

# Verificar si los certificados ya existen para no regenerarlos
if [ ! -f /etc/nginx/ssl/lucia-ma.42.fr.crt ] || [ ! -f /etc/nginx/ssl/lucia-ma.42.fr.key ]; then
    echo "Generando nuevos certificados SSL..."
    
    # Generar clave privada
    openssl genrsa -out /etc/nginx/ssl/lucia-ma.42.fr.key 2048
    
    # Generar certificado auto-firmado
    openssl req -new -x509 -nodes \
        -key /etc/nginx/ssl/lucia-ma.42.fr.key \
        -out /etc/nginx/ssl/lucia-ma.42.fr.crt \
        -days 365 \
        -subj "/C=ES/ST=Madrid/L=Madrid/O=42Madrid/CN=lucia-ma.42.fr"
    
    echo "✓ Certificados SSL generados exitosamente"
else
    echo "✓ Certificados SSL ya existen, saltando generación"
fi

# Asegurar permisos correctos
chmod 600 /etc/nginx/ssl/lucia-ma.42.fr.key
chmod 644 /etc/nginx/ssl/lucia-ma.42.fr.crt

echo "=== SSL setup completado ==="
