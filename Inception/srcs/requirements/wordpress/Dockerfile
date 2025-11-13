FROM debian:bullseye

RUN apt-get update -y && \
    apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Configurar PHP-FPM
RUN sed -i 's/listen = .*/listen = 9000/g' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/;listen.owner = www-data/listen.owner = www-data/g' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/;listen.group = www-data/listen.group = www-data/g' /etc/php/7.4/fpm/pool.d/www.conf && \
    sed -i 's/;daemonize = yes/daemonize = no/g' /etc/php/7.4/fpm/php-fpm.conf

# Instalar WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Crear directorios necesarios
RUN mkdir -p /run/php && \
    mkdir -p /var/www/wordpress && \
    chown -R www-data:www-data /var/www/wordpress

# Copiar configuración de PHP-FPM
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copiar script de configuración
COPY tools/setup-wordpress.sh /setup-wordpress.sh
RUN chmod +x /setup-wordpress.sh

WORKDIR /var/www/wordpress

EXPOSE 9000

ENTRYPOINT ["/setup-wordpress.sh"]
