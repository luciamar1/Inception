#!/bin/bash
set -e

echo "🔧 Iniciando WordPress..."

# Leer de variables de entorno (NO más secrets)
DB_PASSWORD=${DB_PASSWORD}

# Esperar a MariaDB
echo "⏳ Esperando a MariaDB..."
until mysql -h mariadb -u wpuser -p${DB_PASSWORD} -e "SELECT 1;" &>/dev/null; do
    sleep 2
done

echo "✅ Conectado a MariaDB"

cd /var/www/wordpress

# Configurar WordPress si no existe
if [ ! -f wp-config.php ]; then
    echo "📥 Descargando WordPress..."
    wp core download --allow-root --force
   
    echo "⚙️ Creando configuración..."
    wp config create \
        --dbname=wordpress \
        --dbuser=wpuser \
        --dbpass=${DB_PASSWORD} \
        --dbhost=mariadb \
        --allow-root \
        --force
   
    echo "🚀 Instalando WordPress..."
    wp core install \
        --url=https://${DOMAIN_NAME} \
        --title="Inception" \
        --admin_user=${WP_USER} \
        --admin_password=1234Martin \
        --admin_email=${WP_EMAIL} \
        --skip-email \
        --allow-root
   
    echo "✅ WordPress instalado"
else
    echo "✅ WordPress ya está configurado"
fi

# Permisos
chown -R www-data:www-data /var/www/wordpress

echo "🎉 Iniciando PHP-FPM..."

# Verificar qué versión de PHP-FPM está disponible
echo "🔍 Buscando PHP-FPM..."
find /usr -name "*fpm*" -type f 2>/dev/null | grep -E "(php.*fpm|fpm)" || echo "No se encontraron binarios fpm"

# Intentar con el binario estándar
if command -v php-fpm8.4 >/dev/null 2>&1; then
    echo "✓ Usando php-fpm8.4"
    exec php-fpm8.4 -F -R
elif command -v php-fpm8.3 >/dev/null 2>&1; then
    echo "✓ Usando php-fpm8.3"
    exec php-fpm8.3 -F -R
elif command -v php-fpm8.2 >/dev/null 2>&1; then
    echo "✓ Usando php-fpm8.2"
    exec php-fpm8.2 -F -R
elif command -v php-fpm8.1 >/dev/null 2>&1; then
    echo "✓ Usando php-fpm8.1"
    exec php-fpm8.1 -F -R
elif command -v php-fpm >/dev/null 2>&1; then
    echo "✓ Usando php-fpm"
    exec php-fpm -F -R
else
    echo "❌ ERROR: No se encontró php-fpm"
    echo "📦 Paquetes PHP instalados:"
    dpkg -l | grep php || echo "No hay paquetes PHP"
    echo "💡 Intentando ejecutar el servicio directamente..."
    service php8.4-fpm start || service php8.3-fpm start || service php8.2-fpm start || service php8.1-fpm start || service php-fpm start
    exit 1
fi
