#!/bin/bash
set -e

echo "[setup-wordpress] Iniciando configuración..."

# Leer secret de la base de datos
DB_PASSWORD=$(cat /run/secrets/db_password)
echo "[setup-wordpress] Password leído correctamente"

# Esperar a que MariaDB esté lista y la base de datos exista
echo "[setup-wordpress] Esperando a que MariaDB esté lista..."
counter=0
max_tries=45

while [ $counter -lt $max_tries ]; do
    # Verificar conexión Y que la base de datos wordpress exista
    if mysql -h"mariadb" -u"lucia" -p"${DB_PASSWORD}" -e "USE wordpress; SELECT 1;" &>/dev/null; then
        echo "[setup-wordpress] ✓ Conexión a MariaDB y base de datos wordpress exitosa!"
        break
    else
        echo "[setup-wordpress] Intento $((counter+1))/$max_tries - Base de datos wordpress no disponible"
        # Intentar crear la base de datos si no existe
        mysql -h"mariadb" -u"lucia" -p"${DB_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS wordpress;" 2>/dev/null || true
        sleep 2
    fi
    counter=$((counter+1))
done

if [ $counter -eq $max_tries ]; then
    echo "[setup-wordpress] ERROR: No se pudo conectar a MariaDB o la base de datos wordpress"
    echo "[setup-wordpress] Verificando estado de la base de datos:"
    mysql -h"mariadb" -u"lucia" -p"${DB_PASSWORD}" -e "SHOW DATABASES;" 2>&1 || true
    exit 1
fi

echo "[setup-wordpress] Procediendo con la instalación de WordPress..."

cd /var/www/wordpress

# Instalar WordPress si no existe
if [ ! -f wp-config.php ]; then
    echo "[setup-wordpress] Descargando WordPress..."
    wp core download --allow-root
    
    echo "[setup-wordpress] Creando archivo de configuración..."
    wp config create \
        --dbname="wordpress" \
        --dbuser="lucia" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="mariadb" \
        --allow-root
    
    echo "[setup-wordpress] Instalando WordPress..."
    wp core install \
        --url="https://lucia-ma.42.fr" \
        --title="Inception" \
        --admin_user="lucia-ma" \
        --admin_password="${DB_PASSWORD}" \
        --admin_email="lucia-ma@student.42madrid.com" \
        --skip-email \
        --allow-root
    
    echo "[setup-wordpress] Creando usuario adicional..."
    wp user create "normaluser" "user@42.fr" \
        --user_pass="userpass123" \
        --role=author \
        --allow-root
    
    # Asegurar permisos correctos
    chown -R www-data:www-data /var/www/wordpress
    echo "[setup-wordpress] ✓ WordPress instalado y configurado correctamente!"
else
    echo "[setup-wordpress] WordPress ya está instalado, continuando..."
fi

echo "[setup-wordpress] Iniciando PHP-FPM..."
exec php-fpm7.4 -F
