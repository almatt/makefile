FROM composer:2 as builder

WORKDIR /app

COPY composer.* ./

RUN composer install \
    --ignore-platform-reqs \
    --no-scripts \
    --no-dev

FROM node:14-alpine as npm-builder

RUN apk add --no-cache --update make gcc g++ libc-dev libpng-dev automake autoconf libtool libpng-dev nasm

WORKDIR /var/www

COPY . /var/www

RUN ls -la public/

RUN npm i && npm run prod

FROM php:8.1-fpm-alpine

RUN apk add curl libxml2-dev autoconf libc-dev gcc nginx make \
        libzip-dev \
        zip \
        jq \
    && docker-php-ext-install zip

WORKDIR /var/www

COPY nginx.conf /etc/nginx/http.d/default.conf
COPY . /var/www
COPY --from=npm-builder /var/www/public /var/www/public
COPY --from=builder /app/vendor /var/www/vendor

RUN php artisan package:discover --ansi

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN chown -R www-data:www-data /var/www

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
