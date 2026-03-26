FROM wordpress:php8.2-apache

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80
