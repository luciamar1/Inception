#!/bin/bash

# Script para exportar todo el proyecto Inception
# Guardar como: export_inception_complete.sh

PROJECT_ROOT="/home/lucia/Inception/Inception"
OUTPUT_FILE="inception_complete_export_$(date +%Y%m%d_%H%M%S).txt"

echo "=== EXPORTACIÓN COMPLETA DEL PROYECTO INCEPTION ===" > $OUTPUT_FILE
echo "Fecha: $(date)" >> $OUTPUT_FILE
echo "Directorio: $PROJECT_ROOT" >> $OUTPUT_FILE
echo "===========================================" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Función para mostrar el contenido de un archivo
export_file() {
    local file_path=$1
    local relative_path=${file_path#$PROJECT_ROOT/}
    
    if [ -f "$file_path" ]; then
        echo "=== ARCHIVO: $relative_path ===" >> $OUTPUT_FILE
        echo "=== RUTA COMPLETA: $file_path ===" >> $OUTPUT_FILE
        echo "=== TAMAÑO: $(du -h "$file_path" | cut -f1) ===" >> $OUTPUT_FILE
        echo "=== PERMISOS: $(ls -l "$file_path" | cut -d' ' -f1) ===" >> $OUTPUT_FILE
        echo "=== PROPIETARIO: $(ls -l "$file_path" | cut -d' ' -f3) ===" >> $OUTPUT_FILE
        echo "" >> $OUTPUT_FILE
        echo "--- CONTENIDO ---" >> $OUTPUT_FILE
        cat "$file_path" >> $OUTPUT_FILE
        echo "" >> $OUTPUT_FILE
        echo "--- FIN DE $relative_path ---" >> $OUTPUT_FILE
        echo "===========================================" >> $OUTPUT_FILE
        echo "" >> $OUTPUT_FILE
    fi
}

# Exportar estructura de directorios
echo "=== ESTRUCTURA DE DIRECTORIOS ===" >> $OUTPUT_FILE
tree -a "$PROJECT_ROOT" >> $OUTPUT_FILE 2>/dev/null || find "$PROJECT_ROOT" -type d | sed 's|[^/]*/|- |g' >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Exportar archivos principales

## Secrets (solo nombres por seguridad)
echo "=== SECRETS (NOMBRES SOLAMENTE) ===" >> $OUTPUT_FILE
find "$PROJECT_ROOT/secrets" -type f -exec basename {} \; >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

## Docker Compose
export_file "$PROJECT_ROOT/srcs/docker-compose.yml"

## Archivo .env
export_file "$PROJECT_ROOT/srcs/.env"

## Makefile si existe
if [ -f "$PROJECT_ROOT/Makefile" ]; then
    export_file "$PROJECT_ROOT/Makefile"
fi

# Dockerfiles
echo "=== DOCKERFILES ===" >> $OUTPUT_FILE
export_file "$PROJECT_ROOT/srcs/requirements/mariadb/Dockerfile"
export_file "$PROJECT_ROOT/srcs/requirements/wordpress/Dockerfile"
export_file "$PROJECT_ROOT/srcs/requirements/nginx/Dockerfile"

# Archivos de configuración
echo "=== ARCHIVOS DE CONFIGURACIÓN ===" >> $OUTPUT_FILE
export_file "$PROJECT_ROOT/srcs/requirements/mariadb/conf/50-server.cnf"
export_file "$PROJECT_ROOT/srcs/requirements/mariadb/conf/init.sql"
export_file "$PROJECT_ROOT/srcs/requirements/nginx/conf/default"
export_file "$PROJECT_ROOT/srcs/requirements/wordpress/conf/www.conf"

# Scripts
echo "=== SCRIPTS ===" >> $OUTPUT_FILE
export_file "$PROJECT_ROOT/srcs/requirements/mariadb/tools/start-mariadb.sh"
export_file "$PROJECT_ROOT/srcs/requirements/wordpress/tools/setup-wordpress.sh"
export_file "$PROJECT_ROOT/srcs/requirements/nginx/tools/start-nginx.sh"
export_file "$PROJECT_ROOT/srcs/requirements/nginx/tools/generate-ssl.sh"

# Otros archivos importantes
echo "=== OTROS ARCHIVOS IMPORTANTES ===" >> $OUTPUT_FILE
if [ -f "$PROJECT_ROOT/cookies.txt" ]; then
    export_file "$PROJECT_ROOT/cookies.txt"
fi

# .dockerignore files
echo "=== .DOCKERIGNORE FILES ===" >> $OUTPUT_FILE
export_file "$PROJECT_ROOT/srcs/requirements/mariadb/.dockerignore"
export_file "$PROJECT_ROOT/srcs/requirements/wordpress/.dockerignore"
export_file "$PROJECT_ROOT/srcs/requirements/nginx/.dockerignore"

# Información del sistema
echo "=== INFORMACIÓN DEL SISTEMA ===" >> $OUTPUT_FILE
echo "Sistema: $(uname -a)" >> $OUTPUT_FILE
echo "Docker version: $(docker --version 2>/dev/null || echo 'Docker no disponible')" >> $OUTPUT_FILE
echo "Docker Compose version: $(docker compose version 2>/dev/null || echo 'Docker Compose no disponible')" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Estado actual de contenedores
echo "=== ESTADO DE CONTENEDORES ===" >> $OUTPUT_FILE
docker ps -a >> $OUTPUT_FILE 2>/dev/null || echo "Docker no disponible" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Redes Docker
echo "=== REDES DOCKER ===" >> $OUTPUT_FILE
docker network ls >> $OUTPUT_FILE 2>/dev/null || echo "Docker no disponible" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Volúmenes Docker
echo "=== VOLÚMENES DOCKER ===" >> $OUTPUT_FILE
docker volume ls >> $OUTPUT_FILE 2>/dev/null || echo "Docker no disponible" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

echo "=== EXPORTACIÓN COMPLETADA ===" >> $OUTPUT_FILE
echo "Archivo generado: $OUTPUT_FILE" >> $OUTPUT_FILE
echo "Tamaño total: $(du -h $OUTPUT_FILE | cut -f1)" >> $OUTPUT_FILE

echo "✅ Exportación completada: $OUTPUT_FILE"
