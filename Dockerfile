FROM php:8.2-apache

RUN a2dismod mpm_event || true && \
    a2enmod mpm_prefork rewrite headers || true

COPY . /var/www/html/
