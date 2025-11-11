FROM php:8.1-apache

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install pdo pdo_mysql zip

RUN a2enmod rewrite

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www/html

COPY entrypoint.sh /var/www/html/entrypoint.sh
RUN chmod +x /var/www/html/entrypoint.sh
