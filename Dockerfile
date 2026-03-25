FROM wordpress:latest
RUN chown -R www-data:www-data /var/www/html
EXPOSE 80
