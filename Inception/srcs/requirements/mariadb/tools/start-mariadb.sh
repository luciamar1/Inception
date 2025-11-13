#!/bin/bash
set -e

echo "[start-mariadb] Iniciando script..."

# Leer secrets
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
DB_PASSWORD=$(cat /run/secrets/db_password)

echo "[start-mariadb] Secrets leídos correctamente"

# Crear directorios necesarios
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Inicializar base de datos si no existe
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "[start-mariadb] Inicializando base de datos por primera vez..."
    
    mysql_install_db --user=mysql --ldata=/var/lib/mysql
    
    echo "[start-mariadb] Iniciando MariaDB temporal para configuración inicial..."
    mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    MYSQL_PID=$!
    
    # Esperar a que esté lista
    echo "[start-mariadb] Esperando a que MariaDB temporal esté lista..."
    sleep 15
    
    # Configurar base de datos y usuarios
    echo "[start-mariadb] Configurando base de datos wordpress y usuarios..."
    mysql -S /var/run/mysqld/mysqld.sock << EOF
-- Configurar root
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';

-- Crear base de datos wordpress
CREATE DATABASE IF NOT EXISTS wordpress;

-- Crear usuario lucia con acceso desde cualquier host
CREATE USER IF NOT EXISTS 'lucia'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'lucia'@'%';

-- Crear usuario administrativo (sin 'admin' en el nombre)
CREATE USER IF NOT EXISTS 'lucia-ma'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'lucia-ma'@'%';

-- Limpiar usuarios anónimos y configuraciones de seguridad
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Aplicar cambios
FLUSH PRIVILEGES;
EOF

    echo "[start-mariadb] Base de datos y usuarios creados correctamente"
    
    # Detener MariaDB temporal
    kill ${MYSQL_PID}
    wait ${MYSQL_PID}
else
    echo "[start-mariadb] Base de datos ya existe, verificando configuración..."
    
    # Iniciar MariaDB temporalmente para verificar/crear base de datos
    mysqld --user=mysql --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    MYSQL_PID=$!
    sleep 10
    
    echo "[start-mariadb] Verificando base de datos wordpress..."
    if mysql -S /var/run/mysqld/mysqld.sock -u root -p${DB_ROOT_PASSWORD} -e "USE wordpress" &>/dev/null; then
        echo "[start-mariadb] Base de datos wordpress existe"
    else
        echo "[start-mariadb] Creando base de datos wordpress..."
        mysql -S /var/run/mysqld/mysqld.sock -u root -p${DB_ROOT_PASSWORD} -e "CREATE DATABASE IF NOT EXISTS wordpress;"
        echo "[start-mariadb] Base de datos wordpress creada"
    fi
    
    echo "[start-mariadb] Verificando usuario lucia..."
    if ! mysql -S /var/run/mysqld/mysqld.sock -u root -p${DB_ROOT_PASSWORD} -e "SELECT User FROM mysql.user WHERE User='lucia';" | grep -q lucia; then
        echo "[start-mariadb] Creando usuario lucia..."
        mysql -S /var/run/mysqld/mysqld.sock -u root -p${DB_ROOT_PASSWORD} << EOF
CREATE USER 'lucia'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'lucia'@'%';
FLUSH PRIVILEGES;
EOF
        echo "[start-mariadb] Usuario lucia creado"
    else
        echo "[start-mariadb] Usuario lucia ya existe"
    fi
    
    # Verificar privilegios
    echo "[start-mariadb] Verificando privilegios..."
    mysql -S /var/run/mysqld/mysqld.sock -u root -p${DB_ROOT_PASSWORD} -e "SHOW GRANTS FOR 'lucia'@'%';"
    
    # Detener MariaDB temporal
    kill ${MYSQL_PID}
    wait ${MYSQL_PID}
fi

echo "[start-mariadb] Iniciando MariaDB definitivamente..."
exec mysqld --user=mysql --console
