#!/bin/bash
set -e

echo "🚀 Iniciando configuración de MariaDB..."

# Leer de variables de entorno
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD}
DB_PASSWORD=${DB_PASSWORD}
MYSQL_USER=${MYSQL_USER}
MYSQL_DATABASE=${MYSQL_DATABASE}

# Configurar directorios
echo "📁 Configurando directorios..."
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

# Inicializar si es la primera vez
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "📦 Inicializando base de datos por primera vez..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
    
    # Configuración inicial
    echo "⚙️ Configurando MariaDB (primera ejecución)..."
    mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    MYSQL_PID=$!
    
    # Esperar a que MariaDB esté lista
    echo "⏳ Esperando que MariaDB inicialice..."
    sleep 15
    
    # Configurar usuarios y permisos - ESTA PARTE ES CRÍTICA
    echo "👤 Configurando usuarios y permisos..."
    mysql -S /run/mysqld/mysqld.sock << EOF
-- Configurar root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
CREATE USER 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- Crear base de datos y usuario de WordPress
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Limpieza de seguridad
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1', '%');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

FLUSH PRIVILEGES;
EOF

    echo "✅ Base de datos configurada"
    kill ${MYSQL_PID}
    wait ${MYSQL_PID}
else
    echo "✅ Base de datos ya existe, verificando configuración..."
    
    # Iniciar temporalmente para verificar/configurar
    mysqld --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    MYSQL_PID=$!
    sleep 10
    
    # VERIFICACIÓN Y CREACIÓN DE LA BD - ESTO FALTA
    echo "🔍 Verificando base de datos '${MYSQL_DATABASE}'..."
    mysql -S /run/mysqld/mysqld.sock -p${DB_ROOT_PASSWORD} << EOF
-- Crear base de datos si no existe
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};

-- Crear usuario si no existe y dar permisos
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';

-- Verificar
SHOW DATABASES;
SELECT user, host FROM mysql.user WHERE user = '${MYSQL_USER}';

FLUSH PRIVILEGES;
EOF

    kill ${MYSQL_PID} 2>/dev/null || true
    wait ${MYSQL_PID} 2>/dev/null || true
fi

# Verificar que la configuración permite conexiones remotas
echo "🔧 Asegurando configuración de red..."
sed -i 's/^#bind-address/bind-address/' /etc/mysql/mariadb.conf.d/50-server.cnf || true
sed -i 's/^bind-address.*=.*/bind-address            = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

echo "🌐 Configuración de red:"
grep "bind-address" /etc/mysql/mariadb.conf.d/50-server.cnf || echo "⚠️ No se encontró bind-address"

# Iniciar MariaDB definitivamente
echo "🎉 Iniciando MariaDB con configuración final..."
exec mysqld --user=mysql --console
