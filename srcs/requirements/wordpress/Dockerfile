FROM debian:trixie

RUN apt-get update -y && \
    apt-get install -y \
    php8.4 \
    php8.4-fpm \
    php8.4-mysql \
    php8.4-curl \
    php8.4-xml \
    php8.4-mbstring \
    php8.4-dom \
    php8.4-zip \
    php8.4-intl \
    curl \
    wget \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Configurar directorios necesarios
RUN mkdir -p /run/php && \
    mkdir -p /var/www/wordpress && \
    mkdir -p /var/log/php

# Configurar PHP-FPM
COPY conf/www.conf /etc/php/8.4/fpm/pool.d/www.conf

RUN sed -i 's|;daemonize =.*|daemonize = no|' /etc/php/8.4/fpm/php-fpm.conf

# Instalar WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Verificar que PHP extensions están cargadas
RUN php -m | grep -E "(json|mysql|curl|xml|mbstring|dom|zip)" || echo "Algunas extensiones no están cargadas"

# Copiar script de configuración
COPY tools/setup-wordpress.sh /setup-wordpress.sh
RUN chmod +x /setup-wordpress.sh

# Configurar permisos iniciales
RUN chown -R www-data:www-data /var/www/wordpress

WORKDIR /var/www/wordpress

EXPOSE 9000

ENTRYPOINT ["/setup-wordpress.sh"]
