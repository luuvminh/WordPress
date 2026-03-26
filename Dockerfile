FROM php:8.2-apache

RUN a2dismod mpm_event && \
    a2enmod mpm_prefork rewrite headers

COPY . /var/www/html/
