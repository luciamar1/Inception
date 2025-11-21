#!/bin/bash
ARCHIVO="inception_completo_$(date +%Y%m%d_%H%M%S).txt"
echo "=== BACKUP INCEPTION $(date) ===" > "$ARCHIVO"
echo "" >> "$ARCHIVO"

# Función para agregar contenido de archivos
agregar_archivo() {
    if [ -f "$1" ]; then
        echo "=== ARCHIVO: $1 ===" >> "$ARCHIVO"
        cat "$1" >> "$ARCHIVO"
        echo "" >> "$ARCHIVO"
        echo "=== FIN $1 ===" >> "$ARCHIVO"
        echo "" >> "$ARCHIVO"
    else
        echo "=== ARCHIVO NO ENCONTRADO: $1 ===" >> "$ARCHIVO"
        echo "" >> "$ARCHIVO"
    fi
}

# Función para listar estructura
agregar_estructura() {
    echo "=== ESTRUCTURA DE CARPETAS ===" >> "$ARCHIVO"
    find . -type f -not -path "./$ARCHIVO" | sort >> "$ARCHIVO"
    echo "" >> "$ARCHIVO"
}

# Agregar estructura
agregar_estructura

# Archivos principales
agregar_archivo "cookies.txt"
agregar_archivo "Makefile"
agregar_archivo "writefile.sh"

# Secrets
agregar_archivo "secrets/credentials.txt"
agregar_archivo "secrets/db_password.txt"
agregar_archivo "secrets/db_root_password.txt"

# Configuraciones
agregar_archivo "srcs/requirements/mariadb/conf/50-server.cnf"
agregar_archivo "srcs/requirements/mariadb/conf/init.sql"
agregar_archivo "srcs/requirements/mariadb/Dockerfile"
agregar_archivo "srcs/requirements/mariadb/tools/start-mariadb.sh"

agregar_archivo "srcs/requirements/nginx/conf/default"
agregar_archivo "srcs/requirements/nginx/Dockerfile"
agregar_archivo "srcs/requirements/nginx/tools/generate-ssl.sh"
agregar_archivo "srcs/requirements/nginx/tools/start-nginx.sh"

agregar_archivo "srcs/requirements/wordpress/conf/www.conf"
agregar_archivo "srcs/requirements/wordpress/Dockerfile"
agregar_archivo "srcs/requirements/wordpress/tools/setup-wordpress.sh"

agregar_archivo "srcs/docker-compose.yml"

echo "✅ Backup creado: $ARCHIVO"
echo "Tamaño: $(du -h "$ARCHIVO" | cut -f1)"
