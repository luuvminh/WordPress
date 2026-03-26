FROM wordpress:php8.2-apache

# Fix MPM conflict at build time: disable event/worker, enable only prefork
# mpm_prefork is required for mod_php (not thread-safe)
RUN a2dismod mpm_event mpm_worker 2>/dev/null || true \
    && rm -f /etc/apache2/mods-enabled/mpm_event.conf \
             /etc/apache2/mods-enabled/mpm_event.load \
             /etc/apache2/mods-enabled/mpm_worker.conf \
             /etc/apache2/mods-enabled/mpm_worker.load \
    && a2enmod mpm_prefork 2>/dev/null || true \
    && echo "=== Enabled MPMs ===" \
    && ls /etc/apache2/mods-enabled/ | grep mpm

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80
