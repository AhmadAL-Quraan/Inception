#!/bin/sh

set -e


# Since we have a persistent db throw named voluems, then checking if the config is already exists.
#
#


# WordPress core files 
if [ ! -f /var/www/html/wp-config-sample.php ]; then
    wp core download --allow-root --path=/var/www/html
fi


# Generate wp-config.php with database credentials
if [ ! -f /var/www/html/wp-config.php ]; then

    wp config create \
        --allow-root \
        --path=/var/www/html \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="$(cat /run/secrets/db_password)" \
        --dbhost="mariadb"
fi


# Installs the actual wp
if ! wp core is-installed --allow-root --path=/var/www/html; then
    wp core install \
        --allow-root \
        --path=/var/www/html \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="${WP_ADMIN_EMAIL}"
fi


#Creating the second user (root created while installing it)
if ! wp user get "${WP_USER}" --allow-root --path=/var/www/html >/dev/null 2>&1; then
    wp user create \
        --allow-root \
        --path=/var/www/html \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="$(cat /run/secrets/wp_user_password)" \
        --role=editor
fi


# change user:group for every file in /var/www/html, same user:group from www.conf
chown -R www-data:www-data /var/www/html

exec php-fpm8.2 -F
