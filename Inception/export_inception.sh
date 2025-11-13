#!/bin/bash

# Script para exportar todo el proyecto Inception a un archivo de texto
# Creado para el proyecto Inception de 42

OUTPUT_FILE="inception_project_export.txt"
PROJECT_ROOT="/home/lucia/Inception"

echo "=== EXPORTACIÓN DEL PROYECTO INCEPTION ===" > $OUTPUT_FILE
echo "Fecha: $(date)" >> $OUTPUT_FILE
echo "Usuario: $(whoami)" >> $OUTPUT_FILE
echo "Directorio: $PROJECT_ROOT" >> $OUTPUT_FILE
echo "===========================================" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Función para mostrar la estructura de directorios
echo "=== ESTRUCTURA DE DIRECTORIOS ===" >> $OUTPUT_FILE
find $PROJECT_ROOT -type d | sed 's|/[^/]*$|/|' | sort | uniq >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Función para procesar cada archivo
process_file() {
    local file="$1"
    local relative_path="${file#$PROJECT_ROOT/}"
    
    echo "=== ARCHIVO: $relative_path ===" >> $OUTPUT_FILE
    echo "=== RUTA COMPLETA: $file ===" >> $OUTPUT_FILE
    echo "=== TAMAÑO: $(du -h "$file" | cut -f1) ===" >> $OUTPUT_FILE
    echo "=== PERMISOS: $(ls -la "$file" | cut -d' ' -f1) ===" >> $OUTPUT_FILE
    echo "=== PROPIETARIO: $(ls -la "$file" | cut -d' ' -f3) ===" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
    echo "--- CONTENIDO ---" >> $OUTPUT_FILE
    
    # Verificar si el archivo es de texto y se puede leer
    if file "$file" | grep -q "text"; then
        cat "$file" >> $OUTPUT_FILE 2>/dev/null
    else
        echo "[ARCHIVO BINARIO O NO LEGIBLE - OMITIENDO CONTENIDO]" >> $OUTPUT_FILE
        echo "Tipo: $(file "$file")" >> $OUTPUT_FILE
    fi
    
    echo "" >> $OUTPUT_FILE
    echo "--- FIN DE $relative_path ---" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
    echo "===========================================" >> $OUTPUT_FILE
    echo "" >> $OUTPUT_FILE
}

# Exportar archivos importantes en orden específico
echo "=== ARCHIVOS PRINCIPALES ===" >> $OUTPUT_FILE

# 1. Makefile
if [ -f "$PROJECT_ROOT/Makefile" ]; then
    process_file "$PROJECT_ROOT/Makefile"
fi

# 2. Docker Compose
if [ -f "$PROJECT_ROOT/srcs/docker-compose.yml" ]; then
    process_file "$PROJECT_ROOT/srcs/docker-compose.yml"
fi

# 3. Archivo de entorno
if [ -f "$PROJECT_ROOT/srcs/.env" ]; then
    process_file "$PROJECT_ROOT/srcs/.env"
fi

# 4. Secrets (solo nombres, no contenido por seguridad)
echo "=== SECRETS (NOMBRES SOLAMENTE) ===" >> $OUTPUT_FILE
find "$PROJECT_ROOT/secrets" -type f -exec basename {} \; >> $OUTPUT_FILE 2>/dev/null
echo "" >> $OUTPUT_FILE

# 5. Dockerfiles
echo "=== DOCKERFILES ===" >> $OUTPUT_FILE
find "$PROJECT_ROOT/srcs/requirements" -name "Dockerfile" | while read dockerfile; do
    process_file "$dockerfile"
done

# 6. Archivos de configuración
echo "=== ARCHIVOS DE CONFIGURACIÓN ===" >> $OUTPUT_FILE
find "$PROJECT_ROOT/srcs/requirements" \( -name "*.conf" -o -name "*.cnf" -o -name "default" \) | while read config; do
    process_file "$config"
done

# 7. Scripts
echo "=== SCRIPTS ===" >> $OUTPUT_FILE
find "$PROJECT_ROOT/srcs/requirements" -name "*.sh" | while read script; do
    process_file "$script"
done

# 8. Otros archivos importantes
echo "=== OTROS ARCHIVOS IMPORTANTES ===" >> $OUTPUT_FILE
find "$PROJECT_ROOT/srcs/requirements" \( -name "*.sql" -o -name "*.php" -o -name "www.conf" \) | while read other; do
    process_file "$other"
done

# 9. Todos los demás archivos (excepto binarios y logs)
echo "=== TODOS LOS DEMÁS ARCHIVOS ===" >> $OUTPUT_FILE
find "$PROJECT_ROOT" -type f \( -name "*.txt" -o -name "*.md" -o -name "*.yml" -o -name "*.yaml" \) \
    ! -path "*/.*" ! -name "$OUTPUT_FILE" | while read file; do
    # Excluir archivos muy grandes o binarios
    if file "$file" | grep -q "text" && [ $(stat -c%s "$file" 2>/dev/null || echo "0") -lt 100000 ]; then
        process_file "$file"
    fi
done

# Información del sistema
echo "=== INFORMACIÓN DEL SISTEMA ===" >> $OUTPUT_FILE
echo "Sistema: $(uname -a)" >> $OUTPUT_FILE
echo "Docker version: $(docker --version 2>/dev/null || echo "No disponible")" >> $OUTPUT_FILE
echo "Docker Compose version: $(docker compose version 2>/dev/null || echo "No disponible")" >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Estado de los contenedores
echo "=== ESTADO DE CONTENEDORES ===" >> $OUTPUT_FILE
docker ps -a >> $OUTPUT_FILE 2>/dev/null
echo "" >> $OUTPUT_FILE

# Redes Docker
echo "=== REDES DOCKER ===" >> $OUTPUT_FILE
docker network ls >> $OUTPUT_FILE 2>/dev/null
echo "" >> $OUTPUT_FILE

# Volúmenes Docker
echo "=== VOLÚMENES DOCKER ===" >> $OUTPUT_FILE
docker volume ls >> $OUTPUT_FILE 2>/dev/null
echo "" >> $OUTPUT_FILE

echo "=== EXPORTACIÓN COMPLETADA ===" >> $OUTPUT_FILE
echo "Archivo generado: $OUTPUT_FILE" >> $OUTPUT_FILE
echo "Tamaño total: $(du -h $OUTPUT_FILE | cut -f1)" >> $OUTPUT_FILE

# Mostrar información final
echo ""
echo "✅ Exportación completada!"
echo "📁 Archivo generado: $OUTPUT_FILE"
echo "📊 Tamaño: $(du -h $OUTPUT_FILE | cut -f1)"
echo "📝 Total de líneas: $(wc -l < $OUTPUT_FILE)"
