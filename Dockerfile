FROM alpine:3.5

WORKDIR /app
VOLUME /app

RUN apk add --update mysql mysql-client php7 php7-fpm php7-mbstring php7-curl php7-mcrypt php7-zip php7-pdo php7-mysqlnd php7-pdo_mysql php7-bz2 php7-json php7-phar php7-sqlite3 php7-common php7-exif php7-session php7-gd php7-xml php7-dom php7-iconv php7-imap php7-xdebug php7-ctype php7-bcmath php7-sockets php7-ftp php7-mysqli php7-zlib nginx curl wget && rm -f /var/cache/apk/*

RUN wget -O /usr/bin/composer "https://getcomposer.org/composer.phar" && wget -O /usr/bin/phpunit https://phar.phpunit.de/phpunit.phar && chmod +x /usr/bin/composer /usr/bin/phpunit

COPY my.cnf /etc/mysql/my.cnf
COPY nginx.default.conf /etc/nginx/conf.d/default.conf
COPY lemp-php.ini /etc/php7/conf.d/02_lemp.ini
COPY ./bootstrap.sh /bootstrap.sh

EXPOSE 80
EXPOSE 3306

CMD ["/bootstrap.sh"]