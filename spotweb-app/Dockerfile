FROM php:7.2-fpm-alpine


#ENV DEBIAN_FRONTEND="noninteractive" \
 #  TERM="xterm" \
 #   APTLIST="apache2 php7.2 php7.2-curl php7.2-gd php7.2-gmp php7.2-mysql php7.2-pgsql php7.2-xml php7.2-xmlrpc php7.2-mbstring php7.2-zip git-core cron" \
 #   REFRESHED_AT='2018-04-18'

 # Cleanup

RUN apk update && \
	apk upgrade && \
	apk add git curl curl-dev gettext-dev zip libpng libpng-dev libjpeg-turbo-dev libwebp-dev zlib-dev libxpm-dev && \
    rm -rf /var/lib/apt/lists/* && \
    rm -r /var/www/html && \
    rm -rf /tmp/*

RUN docker-php-ext-install pdo curl pdo_mysql mysqli zip gd gettext

RUN git clone -b master --single-branch https://github.com/spotweb/spotweb.git /var/www/html/spotweb && \
    rm -rf /var/www/html/spotweb/.git && \
    chmod -R 775 /var/www/html/spotweb && \
    chown -R www-data:www-data /var/www/html/spotweb

COPY entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

#COPY files/000-default.conf /etc/apache2/sites-enabled/000-default.conf

VOLUME [ "/config" ]

EXPOSE 9000

ENTRYPOINT ["/entrypoint.sh"]
