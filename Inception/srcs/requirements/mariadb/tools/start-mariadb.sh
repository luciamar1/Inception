#!/bin/bash
set -e

# Leer de variables de entorno (NO más secrets)
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
DB_PASSWORD=${DB_PASSWORD}

# Configurar directorios
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Inicializar si es la primera vez
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 Inicializando base de datos por primera vez..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
   
    # Configuración inicial
    echo "🚀 Configurando MariaDB..."
    mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    MYSQL_PID=$!
   
    sleep 15
   
    mysql -S /run/mysqld/mysqld.sock << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE USER 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;

CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER 'wpuser'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL ON wordpress.* TO 'wpuser'@'%';

DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;

FLUSH PRIVILEGES;
EOF

    echo "✅ Base de datos configurada"
    kill ${MYSQL_PID}
    wait ${MYSQL_PID}
else
    echo "✅ Base de datos ya existe"
fi

# Iniciar MariaDB definitivamente
echo "🎉 Iniciando MariaDB..."
exec mysqld --user=mysql --console
