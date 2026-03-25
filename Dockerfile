FROM wordpress:php8.2-apache

# Clear any pre-existing Apache pid files that cause crashes on restart
RUN rm -f /var/run/apache2/apache2.pid

EXPOSE 80
