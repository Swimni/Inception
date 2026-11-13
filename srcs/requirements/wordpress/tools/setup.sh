#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(grep '^WP_ADMIN_PASSWORD=' /run/secrets/credentials | cut -d '=' -f 2-)
WP_USER_PASSWORD=$(grep '^WP_USER_PASSWORD=' /run/secrets/credentials | cut -d '=' -f 2-)

cd /var/www/html

for i in $(seq 1 30); do
    if mariadb-admin ping -h mariadb --silent 2> /dev/null; then
        break
    fi
    echo "[wordpress] Waiting for MariaDB ($i/30)..."
    sleep 1
done

if [ ! -f wp-load.php ]; then
    echo "[wordpress] Downloading WordPress..."
    wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
    echo "[wordpress] Creating wp-config.php..."
    wp config create --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$DB_PASSWORD" \
        --dbhost=mariadb:3306
fi

if ! wp core is-installed --allow-root 2> /dev/null; then
    echo "[wordpress] Installing WordPress..."
    wp core install --allow-root \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email
    wp user create --allow-root \
        "$WP_USER" "$WP_USER_EMAIL" \
        --role=author \
        --user_pass="$WP_USER_PASSWORD"
fi

chown -R www-data:www-data /var/www/html

echo "[wordpress] Starting php-fpm..."
exec php-fpm8.2 -F
