#!/bin/bash
set -e

echo "🔧 Iniciando configuración de MariaDB..."

# Leer secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

echo "✓ Secrets leídos"

# Crear directorios necesarios
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Inicializar base de datos si no existe
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 Inicializando base de datos por primera vez..."
    
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
    
    echo "🚀 Iniciando MariaDB temporal..."
    mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    MYSQL_PID=$!
    
    # Esperar a que esté lista
    echo "⏳ Esperando a MariaDB..."
    sleep 10
    
    # Configurar base de datos y usuarios
    echo "👤 Configurando usuarios y base de datos..."
    mysql -S /run/mysqld/mysqld.sock << EOF
-- Configurar root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE USER 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Crear base de datos
CREATE DATABASE wordpress;

-- Crear usuarios
CREATE USER 'lucia'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'lucia'@'%';

CREATE USER 'lucia-ma'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'lucia-ma'@'%';

-- Limpiar
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;

FLUSH PRIVILEGES;
EOF

    echo "✓ Base de datos configurada"
    
    # Detener MariaDB temporal
    kill ${MYSQL_PID}
    wait ${MYSQL_PID}
else
    echo "✓ Base de datos ya existe"
fi

echo "🎉 Iniciando MariaDB..."
exec mysqld --user=mysql --console
