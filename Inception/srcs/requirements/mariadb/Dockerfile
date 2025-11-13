FROM debian:bullseye

RUN apt-get update -y && \
    apt-get install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/*

# Copiar configuración de MariaDB
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copiar script de inicio
COPY tools/start-mariadb.sh /start-mariadb.sh
RUN chmod +x /start-mariadb.sh

# Crear directorio para sockets
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld

# Volumen para la base de datos
VOLUME ["/var/lib/mysql"]

# Exponer puerto
EXPOSE 3306

# Punto de entrada
ENTRYPOINT ["/start-mariadb.sh"]
