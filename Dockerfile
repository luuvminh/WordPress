FROM wordpress:php8.2-apache

# Bake a correct .htaccess template into the image (with FollowSymLinks required for mod_rewrite)
RUN printf '# BEGIN WordPress\n<IfModule mod_rewrite.c>\nOptions +FollowSymLinks\nRewriteEngine On\nRewriteBase /\nRewriteRule ^index\\.php$ - [L]\nRewriteCond %%{REQUEST_FILENAME} !-f\nRewriteCond %%{REQUEST_FILENAME} !-d\nRewriteRule . /index.php [L]\n</IfModule>\n# END WordPress\n' > /htaccess-template

# Inject MPM cleanup + .htaccess restore into apache2-foreground so it runs AFTER all volume mounts
RUN { head -1 /usr/local/bin/apache2-foreground; \
        echo 'rm -f /etc/apache2/mods-enabled/mpm_event.conf /etc/apache2/mods-enabled/mpm_event.load'; \
        echo 'rm -f /etc/apache2/mods-enabled/mpm_worker.conf /etc/apache2/mods-enabled/mpm_worker.load'; \
        echo 'rm -f /etc/apache2/mods-enabled/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.load'; \
        echo 'ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf'; \
        echo 'ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load'; \
        echo 'grep -q FollowSymLinks /var/www/html/.htaccess 2>/dev/null || cp /htaccess-template /var/www/html/.htaccess'; \
        tail -n +2 /usr/local/bin/apache2-foreground; \
    } > /tmp/apache2-foreground \
        && mv /tmp/apache2-foreground /usr/local/bin/apache2-foreground \
        && chmod +x /usr/local/bin/apache2-foreground

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80
