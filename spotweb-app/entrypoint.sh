#!/bin/ash

if [ ! -f /config/ownsettings.php ] && [ -f /var/www/html/spotweb/ownsettings.php ]; then
  cp /var/www/html/spotweb/ownsettings.php /config/ownsettings.php
fi

touch /config/ownsettings.php && chown www-data:www-data /config/ownsettings.php
rm -f /var/www/html/spotweb/ownsettings.php
ln -s /config/ownsettings.php /var/www/html/spotweb/ownsettings.php

chown -R www-data:www-data /var/www/spotweb

if [[ -n "$SPOTWEB_DB_TYPE" && -n "$SPOTWEB_DB_HOST" && -n "$SPOTWEB_DB_NAME" && -n "$SPOTWEB_DB_USER" && -n "$SPOTWEB_DB_PASS" ]]; then
    echo "Creating database configuration"
    echo "<?php" > /config/dbsettings.inc.php
    echo "\$dbsettings['engine'] = '$SPOTWEB_DB_TYPE';" >> /config/dbsettings.inc.php
    echo "\$dbsettings['host'] = '$SPOTWEB_DB_HOST';" >> /config/dbsettings.inc.php
    echo "\$dbsettings['dbname'] = '$SPOTWEB_DB_NAME';"  >> /config/dbsettings.inc.php
    echo "\$dbsettings['user'] = '$SPOTWEB_DB_USER';" >> /config/dbsettings.inc.php
    echo "\$dbsettings['pass'] = '$SPOTWEB_DB_PASS';"  >> /config/dbsettings.inc.php
fi

if [ -f /config/dbsettings.inc.php ]; then
	chown www-data:www-data /config/dbsettings.inc.php
	rm /var/www/html/spotweb/dbsettings.inc.php
	ln -s /config/dbsettings.inc.php /var/www/html/spotweb/dbsettings.inc.php
else
	echo -e "\nWARNING: You have no database configuration file, either create /config/dbsettings.inc.php or restart this container with the correct environment variables to auto generate the config.\n"
fi

TZ=${TZ:-"Australia/Sydney"}
echo -e "Setting (PHP) time zone to ${TZ}\n"
#RUN printf '[PHP]\ndate.timezone = "US/Central"\n' > /usr/local/etc/php/conf.d/tzone.ini

echo "[PHP]\ndate.timezone = ${TZ}"  >> /usr/local/etc/php-fpm.d/tzone.ini
#sed -i "s#^;date.timezone =.*#date.timezone = ${TZ}#g"  /etc/php/7.*/*/php.ini

if [[ -n "$SPOTWEB_CRON_RETRIEVE" || -n "$SPOTWEB_CRON_CACHE_CHECK" ]]; then
    ln -sf /proc/$$/fd/1 /var/log/stdout
    service cron start
	if [[ -n "$SPOTWEB_CRON_RETRIEVE" ]]; then
        echo "$SPOTWEB_CRON_RETRIEVE su -l www-data -s /usr/bin/php /var/www/html/spotweb/retrieve.php >/var/log/stdout 2>&1" > /etc/crontab
	fi
	if [[ -n "$SPOTWEB_CRON_CACHE_CHECK" ]]; then
        echo "$SPOTWEB_CRON_CACHE_CHECK su -l www-data -s /usr/bin/php /var/www/html/spotweb/bin/check-cache.php >/var/log/stdout 2>&1" >> /etc/crontab
	fi
    crontab /etc/crontab
fi

# # Run database update
sleep 30
php /var/www/html/spotweb/bin/upgrade-db.php #>/dev/null 2>&1

# # Clean up apache pid (if there is one)
# rm -rf /run/apache2/apache2.pid

# # Enabling PHP mod rewrite
# /usr/sbin/a2enmod rewrite && /etc/init.d/apache2 restart

# tail -F /var/log/apache2/* /dev/stdout /dev/stderr
php-fpm