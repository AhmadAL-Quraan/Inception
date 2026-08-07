

## Dockerfile




## Dockerfile

```Dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y mariadb-server && rm -rf /var/lib/mysql/*
COPY ./tools/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

COPY conf/my.cnf /etc/mysql/mariadb.conf.d/99-custom.cnf

EXPOSE 3306

ENTRYPOINT ["/entrypoint.sh"]
```


## Entrypoint

```bash
#!/bin/sh

set -e 

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	mariadb-install-db \
		--user=mysql \
		--datadir=/var/lib/mysql \
		--skip-test-db > /dev/null
	mariadbd --user=mysql --datadir=/var/lib/mysql &

	until mysqladmin ping --silent; do
    		sleep 1
	done

	mariadb -u root <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$(cat /run/secrets/db_root_password)';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '$(cat /run/secrets/db_password)';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    FLUSH PRIVILEGES;
	EOSQL


	mysqladmin -u root -p"$(cat /run/secrets/db_root_password)" shutdown

fi 

exec mariadbd --user=mysql --datadir=/var/lib/mysql
```

This script is used to make the database inside the container with the database name and user and password, then run it in the background as pid 1.



## Mariadb config

```cnf
[mysqld]
# listen on all interfaces so WordPress container can reach it
# (by default MariaDB only listens on localhost, which breaks container networking)
bind-address = 0.0.0.0

# port (default, but explicit is better)
port = 3306

# where data is stored, should match your named volume mount point
datadir = /var/lib/mysql

# socket file location
socket = /run/mysqld/mysqld.sock
``` 

* Used to bind mariadb to listen on all networks on port 3306, instead of only localhost.


---

## Unix sockets vs TCP socket

* Unix sockets: used for communication between two processes on the same machine.
* TCP socket: used for communication between two process over the network (not on the same machine).
### Why does MariaDB use _both_ at once?

Because it's a common Linux/database convention to support **two different ways to connect**, for two different scenarios:

**Unix socket**: used when a client and the database are on the **exact same machine/container**. It's **faster** than TCP (skips the network stack entirely — no IP routing, no port numbers, just a direct kernel-level pipe) and is the **default** connection method many MySQL/MariaDB client tools use automatically when you just type `mysql` with no extra flags, if you're on the same machine as the server.

**TCP socket**: used when the client is on a **different machine (or container)** and needs to reach the database over an actual network. This is what your `wordpress` container needs, since it's a completely separate container from `mariadb`.