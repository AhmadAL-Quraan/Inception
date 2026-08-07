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
