#!/bin/bash

# Uso: ./writefile.sh ruta/al/archivo
# Luego pega el contenido que quieras y termina con Ctrl+D

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 ruta/al/archivo"
    exit 1
fi

FILE="$1"

echo "Introduce el contenido que quieres escribir en $FILE. Termina con Ctrl+D."

# Reescribe el archivo con el contenido leído desde stdin
cat > "$FILE"

echo "Archivo $FILE reescrito correctamente."
