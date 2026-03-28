FROM wordpress:php8.2-apache

# Fix MPM: inject prefork cleanup into apache2-foreground so it runs AFTER volume mounts
RUN { head -1 /usr/local/bin/apache2-foreground; \
        echo 'rm -f /etc/apache2/mods-enabled/mpm_event.conf /etc/apache2/mods-enabled/mpm_event.load'; \
        echo 'rm -f /etc/apache2/mods-enabled/mpm_worker.conf /etc/apache2/mods-enabled/mpm_worker.load'; \
        echo 'rm -f /etc/apache2/mods-enabled/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.load'; \
        echo 'ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf'; \
        echo 'ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load'; \
        tail -n +2 /usr/local/bin/apache2-foreground; \
    } > /tmp/apache2-foreground \
        && mv /tmp/apache2-foreground /usr/local/bin/apache2-foreground \
        && chmod +x /usr/local/bin/apache2-foreground

# Permanent fix for mod_rewrite 403: set Options +FollowSymLinks at the Apache server
# config level — NOT in .htaccess. WordPress calls flush_rewrite_rules() on admin saves
# and rewrites .htaccess without FollowSymLinks, causing 403. Fixing it here means
# .htaccess never needs this option and WordPress can manage .htaccess freely.
RUN printf '<Directory /var/www/html>\n    Options +FollowSymLinks\n</Directory>\n' \
    > /etc/apache2/conf-available/wp-followsymlinks.conf \
    && a2enconf wp-followsymlinks

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80
