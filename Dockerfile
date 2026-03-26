FROM wordpress:php8.2-apache

# DIAGNOSTIC: show exactly where Apache's MPM config lives
RUN echo "=== which apache2 ===" && which apache2 2>/dev/null || true \
    && echo "=== apache2-foreground script ===" && cat /usr/local/bin/apache2-foreground 2>/dev/null || true \
    && echo "=== /usr/local/apache2/conf/httpd.conf LoadModule mpm lines ===" \
    && grep -n "mpm" /usr/local/apache2/conf/httpd.conf 2>/dev/null || echo "(no httpd.conf)" \
    && echo "=== /etc/apache2/mods-enabled mpm files ===" \
    && ls -la /etc/apache2/mods-enabled/ 2>/dev/null | grep mpm || echo "(no mods-enabled mpm files)" \
    && echo "=== all mpm.load files in /usr/local ===" \
    && find /usr/local -name "*mpm*" 2>/dev/null || echo "(none)"

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80
