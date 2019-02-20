FROM php:7.3.2-fpm-alpine3.9
MAINTAINER mesaque.s.silva@gmail.com

RUN apk update && \
	apk upgrade && \
	apk add --no-cache freetype libpng libjpeg-turbo freetype-dev libpng-dev libjpeg-turbo-dev libxml2-dev curl-dev  libmcrypt-dev libpq cyrus-sasl-dev libzip libzip-dev libmemcached-dev msmtp pcre-dev zlib-dev git zip bash vim sudo bind-tools && \
  	docker-php-ext-configure gd \
    --with-gd \
    --with-freetype-dir=/usr/include/ \
    --with-png-dir=/usr/include/ \
    --with-jpeg-dir=/usr/include/ && \
  NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) && \
  docker-php-ext-install -j${NPROC} gd && \
  apk del --no-cache freetype-dev libpng-dev libjpeg-turbo-dev

RUN apk add --no-cache \
        $PHPIZE_DEPS \
    && echo '' | pecl install memcached \
    && echo "extension=memcached.so" > /usr/local/etc/php/conf.d/20_memcached.ini

RUN cd /usr/bin && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && mv /usr/bin/wp-cli.phar /usr/bin/wp && chmod +x /usr/bin/wp

RUN docker-php-ext-install zip mysqli sockets soap calendar bcmath opcache
RUN deluser www-data && deluser xfs
RUN echo "www-data:x:33:33:Apiki WP Host,,,:/var/www:/bin/false" >> /etc/passwd && echo "www-data:x:33:www-data" >> /etc/group
WORKDIR /var/www
USER www-data