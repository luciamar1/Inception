#!/bin/bash
set -e

echo "🔧 Iniciando WordPress..."

# Leer password
DB_PASSWORD=$(cat /run/secrets/db_password)

# Esperar máximo 30 segundos
echo "⏳ Esperando a MariaDB (máximo 30s)..."
for i in {1..15}; do
    if mysql -h mariadb -u lucia -p${DB_PASSWORD} -e "SELECT 1;" 2>/dev/null; then
        echo "✓ Conectado a MariaDB"
        break
    fi
    echo "Intento $i/15 - Esperando..."
    sleep 2
done

# Verificar conexión final
if ! mysql -h mariadb -u lucia -p${DB_PASSWORD} -e "USE wordpress;" 2>/dev/null; then
    echo "❌ ERROR: No se pudo conectar a MariaDB"
    echo "Intentando crear base de datos..."
    mysql -h mariadb -u root -p${DB_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS wordpress;" 2>/dev/null || true
    mysql -h mariadb -u root -p${DB_PASSWORD} -e "GRANT ALL ON wordpress.* TO 'lucia'@'%';" 2>/dev/null || true
fi

cd /var/www/wordpress

# Instalar WordPress si no existe
if [ ! -f wp-config.php ]; then
    echo "📥 Descargando WordPress..."
    wp core download --allow-root
    
    echo "⚙️ Configurando WordPress..."
    wp config create \
        --dbname=wordpress \
        --dbuser=lucia \
        --dbpass=${DB_PASSWORD} \
        --dbhost=mariadb \
        --allow-root
    
    echo "🚀 Instalando WordPress..."
    wp core install \
        --url=https://lucia-ma.42.fr \
        --title=Inception \
        --admin_user=lucia-ma \
        --admin_password=${DB_PASSWORD} \
        --admin_email=lucia-ma@student.42madrid.com \
        --skip-email \
        --allow-root
    
    echo "✅ WordPress instalado"
else
    echo "✓ WordPress ya instalado"
fi

# Permisos
chown -R www-data:www-data /var/www/wordpress

echo "🎉 Iniciando PHP-FPM..."
exec php-fpm7.4 -F
