FROM debian:trixie

RUN apt-get update -y && \
    apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    php-curl \
    php-json \
    php-xml \
    php-mbstring \
    curl \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Configurar directorios necesarios
RUN mkdir -p /run/php && \
    mkdir -p /var/www/wordpress

# Configurar PHP-FPM
RUN sed -i 's|^listen =.*|listen = 9000|' /etc/php/*/fpm/pool.d/www.conf && \
    sed -i 's|;listen.owner =.*|listen.owner = www-data|' /etc/php/*/fpm/pool.d/www.conf && \
    sed -i 's|;listen.group =.*|listen.group = www-data|' /etc/php/*/fpm/pool.d/www.conf && \
    sed -i 's|;daemonize =.*|daemonize = no|' /etc/php/*/fpm/php-fpm.conf

# Instalar WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Copiar configuración de PHP-FPM
COPY conf/www.conf /etc/php/*/fpm/pool.d/www.conf

# Copiar script de configuración
COPY tools/setup-wordpress.sh /setup-wordpress.sh
RUN chmod +x /setup-wordpress.sh

# Configurar permisos
RUN chown -R www-data:www-data /var/www/wordpress

WORKDIR /var/www/wordpress

EXPOSE 9000

ENTRYPOINT ["/setup-wordpress.sh"]
