FROM nginx:mainline-alpine

 # Cleanup
RUN apk update && \
	apk upgrade && \
	apk add git && \
    rm -rf /var/lib/apt/lists/*

RUN git clone -b master --single-branch https://github.com/spotweb/spotweb.git /var/www/html/spotweb && \
    rm -rf /var/www/html/spotweb/.git && \
    chmod -R 775 /var/www/html/spotweb && \
    chown -R nginx:nginx /var/www/html/spotweb


COPY nginx.conf /etc/nginx/nginx.conf
COPY 000-default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
WORKDIR /var/www/html/spotweb/
