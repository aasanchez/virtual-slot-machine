FROM php:7.2-fpm
RUN apt-get update \
    && apt-get install sudo \
    && apt-get install -y libpq-dev wget git unzip zip \
    && apt-get clean \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
