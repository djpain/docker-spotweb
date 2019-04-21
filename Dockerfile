FROM httpd:2.4-alpine

#ENV DEBIAN_FRONTEND="noninteractive" \
#    TERM="xterm" \
#    APTLIST="apache2 php7.2 php7.2-curl php7.2-gd php7.2-gmp php7.2-mysql php7.2-pgsql php7.2-xml php7.2-xmlrpc php7.2-mbstring php7.2-zip git-core cron" \
#    REFRESHED_AT='2018-04-18'

#RUN echo "force-unsafe-io" > /etc/dpkg/dpkg.cfg.d/02apt-speedup &&\
#    echo "Acquire::http {No-Cache=True;};" > /etc/apt/apt.conf.d/no-cache && \
#    apt-get -q update && \
#    apt-get -qy dist-upgrade && \
#    apt-get install -qy $APTLIST && \
#    \
    # Cleanup
#    apt-get -y autoremove && \
#    apt-get -y clean && \
#    rm -rf /var/lib/apt/lists/* && \
#    rm -r /var/www/html && \
#    rm -rf /tmp/*
Run apk update && apk upgrade 

RUN apk add git lynx php7 php7-apache2  php7-curl php7-gd php7-gmp php7-mysqli php7-pgsql php7-xml php7-xmlrpc php7-mbstring php7-zip php7-apache2 curl ca-certificates openssl openssh git php7 php7-phar php7-json php7-iconv php7-openssl tzdata openntpd

RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

RUN apk add \
	php7-ftp \
	php7-xdebug \
	php7-mcrypt \
	php7-mbstring \
	php7-soap \
	php7-gmp \
	php7-pdo_odbc \
	php7-dom \
	php7-pdo \
	php7-zip \
	php7-mysqli \
	php7-sqlite3 \
	php7-pdo_pgsql \
	php7-bcmath \
	php7-gd \
	php7-odbc \
	php7-pdo_mysql \
	php7-pdo_sqlite \
	php7-gettext \
	php7-xmlreader \
	php7-xmlwriter \
	php7-tokenizer \
	php7-xmlrpc \
	php7-bz2 \
	php7-pdo_dblib \
	php7-curl \
	php7-ctype \
	php7-session \
	php7-redis \
	php7-exif

# Problems installing in above stack
RUN apk add php7-simplexml && rm -f /var/cache/apk/*

RUN git clone -b master --single-branch https://github.com/spotweb/spotweb.git /usr/local/apache2/htdocs/spotweb && \
    rm -rf /usr/local/apache2/htdocs/spotweb/.git && \
    chmod -R 775 /usr/local/apache2/htdocs/spotweb

RUN  echo "Composer install" && cd /usr/local/apache2/htdocs/spotweb && composer install

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod u+x /entrypoint.sh

COPY files/000-default.conf /usr/local/apache2/conf/httpd.conf

VOLUME [ "/config" ]

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
