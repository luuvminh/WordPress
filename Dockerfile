FROM wordpress:latest

# This line forces Apache to use the Port Railway provides
RUN sed -i 's/Listen 80/Listen ${PORT}/g' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost *:${PORT}>/g' /etc/apache2/sites-enabled/000-default.conf

EXPOSE 80
