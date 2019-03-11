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

RUN echo '' | pecl install redis
RUN cd /usr/bin && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && mv /usr/bin/wp-cli.phar /usr/bin/wp && chmod +x /usr/bin/wp

RUN docker-php-ext-install zip mysqli sockets soap calendar bcmath opcache
RUN docker-php-ext-enable redis

RUN cd /root/ && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
  php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
  php composer-setup.php && \
  mv /root/composer.phar /usr/bin/composer

RUN deluser www-data && deluser xfs
RUN echo "www-data:x:33:33:K4izen Cloud Service,,,:/var/www:/bin/false" >> /etc/passwd && echo "www-data:x:33:www-data" >> /etc/group

RUN mkdir /PROJECT && chown www-data:www-data /PROJECT
RUN mkdir -p /var/www && chown -R www-data:www-data /var/www

WORKDIR /PROJECT

USER www-data 
