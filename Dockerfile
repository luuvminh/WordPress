FROM wordpress:php8.2-apache

# The Apache binary in this image has mpm_prefork compiled in as default.
# Loading mpm_prefork.load (or mpm_event.load) from mods-enabled on top
# of the built-in causes AH00534 "More than one MPM loaded".
# Fix: remove ALL mpm module files - the built-in prefork will be used.
RUN rm -f /etc/apache2/mods-enabled/mpm_*.conf \
          /etc/apache2/mods-enabled/mpm_*.load

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80
