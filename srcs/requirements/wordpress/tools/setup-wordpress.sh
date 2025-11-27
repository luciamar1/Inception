#!/bin/bash
set -e

echo "🔧 Iniciando WordPress..."

# Leer de variables de entorno
DB_PASSWORD=${DB_PASSWORD}
DOMAIN_NAME=${DOMAIN_NAME}
WP_USER=${WP_USER}
WP_EMAIL=${WP_EMAIL}

# Verificar que las variables de entorno están seteadas
if [ -z "$DB_PASSWORD" ]; then
    echo "❌ ERROR: DB_PASSWORD no está definida"
    exit 1
fi

echo "📋 Variables de entorno:"
echo "   DOMAIN_NAME: $DOMAIN_NAME"
echo "   WP_USER: $WP_USER"
echo "   WP_EMAIL: $WP_EMAIL"

# Esperar a MariaDB con timeout
echo "⏳ Esperando a MariaDB..."
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if mysql -h mariadb -u wpuser -p${DB_PASSWORD} wordpress -e "SELECT 1;" &>/dev/null; then
        echo "✅ Conectado a MariaDB y base de datos accesible"
        break
    fi
    echo "⏳ Intento $((RETRY_COUNT + 1))/$MAX_RETRIES - Esperando MariaDB..."
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "❌ ERROR: No se pudo conectar a la base de datos después de $MAX_RETRIES intentos"
    echo "💡 Verificando estado..."
    mysql -h mariadb -u wpuser -p${DB_PASSWORD} -e "SHOW DATABASES;" || echo "❌ No se puede conectar"
    exit 1
fi

cd /var/www/wordpress

# Verificar si WordPress ya está instalado
if wp core is-installed --allow-root 2>/dev/null; then
    echo "✅ WordPress ya está instalado y configurado"
else
    echo "📥 WordPress no está instalado, procediendo con instalación..."
    
    # Descargar WordPress si no existe
    if [ ! -f wp-config.php ]; then
        echo "📥 Descargando WordPress..."
        wp core download --allow-root --force
    fi
    
    # Crear configuración
    if [ ! -f wp-config.php ]; then
        echo "⚙️ Creando configuración de WordPress..."
        wp config create \
            --dbname=wordpress \
            --dbuser=wpuser \
            --dbpass=${DB_PASSWORD} \
            --dbhost=mariadb \
            --allow-root \
            --force
    fi
    
    # Verificar que podemos acceder a la base de datos
    echo "🔍 Verificando acceso a base de datos..."
    if mysql -h mariadb -u wpuser -p${DB_PASSWORD} wordpress -e "SHOW TABLES;" &>/dev/null; then
        echo "✅ Base de datos accesible"
    else
        echo "❌ No se puede acceder a la base de datos 'wordpress'"
        echo "💡 Creando base de datos si no existe..."
        mysql -h mariadb -u root -p${DB_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS wordpress; GRANT ALL ON wordpress.* TO 'wpuser'@'%';" 2>/dev/null || echo "⚠️ No se pudo crear BD"
    fi
    
    # Instalar WordPress
    echo "🚀 Instalando WordPress..."
    wp core install \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_USER} \
        --admin_password=1234Martin \
        --admin_email=${WP_EMAIL} \
        --skip-email \
        --allow-root
    
    # Verificar instalación
    if wp core is-installed --allow-root; then
        echo "✅ WordPress instalado correctamente en https://${DOMAIN_NAME}"
        echo "👤 Usuario admin: ${WP_USER}"
        echo "🔐 Password: 1234Martin"
    else
        echo "❌ ERROR: WordPress no se pudo instalar"
        echo "💡 Puedes completar la instalación manualmente en https://${DOMAIN_NAME}"
    fi
fi

# Configurar permisos
echo "🔧 Configurando permisos..."
chown -R www-data:www-data /var/www/wordpress
find /var/www/wordpress -type d -exec chmod 755 {} \;
find /var/www/wordpress -type f -exec chmod 644 {} \;

# Permisos específicos para wp-config.php
if [ -f wp-config.php ]; then
    chmod 640 wp-config.php
fi

# Crear directorio para PHP-FPM
mkdir -p /run/php
chown www-data:www-data /run/php

echo "🎉 Iniciando PHP-FPM 8.4..."
exec php-fpm8.4 -F -R
