#!/bin/bash

echo "=== VERIFICACIÓN PROYECTO INCEPTION ==="

echo "1. Estructura de carpetas:"
find . -type f -name ".env" -o -name "*.txt" | grep -E "(\.env|secrets/)" | sort

echo -e "\n2. Archivo .env:"
if [ -f "srcs/.env" ]; then
    echo "✓ Existe: srcs/.env"
    cat srcs/.env
else
    echo "✗ NO existe: srcs/.env"
fi

echo -e "\n3. Archivos de secrets:"
if [ -f "secrets/db_password.txt" ]; then
    echo "✓ Existe: secrets/db_password.txt"
    echo "Contenido: $(cat secrets/db_password.txt)"
else
    echo "✗ NO existe: secrets/db_password.txt"
fi

if [ -f "secrets/db_root_password.txt" ]; then
    echo "✓ Existe: secrets/db_root_password.txt"
    echo "Contenido: $(cat secrets/db_root_password.txt)"
else
    echo "✗ NO existe: secrets/db_root_password.txt"
fi

echo -e "\n4. Permisos:"
ls -la secrets/ 2>/dev/null | grep ".txt" || echo "No se encontraron archivos secrets"

echo "=== FIN VERIFICACIÓN ==="
