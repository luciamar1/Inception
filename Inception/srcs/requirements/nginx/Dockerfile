FROM debian:trixie

RUN apt-get update -y && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Crear directorios necesarios
RUN mkdir -p /etc/nginx/ssl && \
    mkdir -p /var/run/nginx

# Copiar configuración
COPY conf/default /etc/nginx/conf.d/default.conf

# Copiar script de inicio
COPY tools/start-nginx.sh /start-nginx.sh
RUN chmod +x /start-nginx.sh

# Exponer puerto
EXPOSE 443

# Usar el script de inicio
CMD ["/start-nginx.sh"]
