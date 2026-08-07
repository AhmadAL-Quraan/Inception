FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/mysql/*
COPY ./tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/99-custom.cnf

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]
