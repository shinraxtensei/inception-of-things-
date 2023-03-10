
#!/bin/sh

mkdir -p /var/www/html
mkdir -p /run/php
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
mv wp-cli.phar /usr/local/bin/wp 

sed -i -e 's/listen =.*/listen = 9000/g' /etc/php/7.3/fpm/pool.d/www.conf

wp core download --path="/var/www/html"  --allow-root
chown -R www-data:www-data /var/www/html


wp config create --dbname=$MYSQL_DATABASE --dbuser=$MYSQL_USER --dbpass=$MYSQL_PASSWORD --dbhost=$WP_DBHOST --path=/var/www/html --allow-root --skip-check --extra-php <<PHP
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
define('WP_REDIS_DISABLED', false);
PHP


wp core install --allow-root --url="$WP_URL" --title="$WP_TITLE" --admin_user="$WP_ADMIN" --admin_password="$WP_ADMIN_PWD" --admin_email="$WP_ADMIN_EMAIL"  --path=/var/www/html --skip-email
wp user create $WP_USER $WP_USER_EMAIL  --user_pass=$WP_USER_PWD --role=author  --path=/var/www/html --allow-root

wp plugin install redis-cache --path=/var/www/html --allow-root
wp plugin activate redis-cache --path=/var/www/html --allow-root
wp redis enable --path=/var/www/html --allow-root

php-fpm7.3 -F