FROM wordpress:php8.2-apache

# Inject MPM cleanup + .htaccess reset into apache2-foreground so it runs AFTER all volume mounts
# This ensures any runtime-restored mpm_event/worker files are removed last
# and .htaccess is always a valid WordPress config (fixes AH01797 403 errors)
RUN { head -1 /usr/local/bin/apache2-foreground; \
      echo 'rm -f /etc/apache2/mods-enabled/mpm_event.conf /etc/apache2/mods-enabled/mpm_event.load'; \
      echo 'rm -f /etc/apache2/mods-enabled/mpm_worker.conf /etc/apache2/mods-enabled/mpm_worker.load'; \
      echo 'rm -f /etc/apache2/mods-enabled/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.load'; \
      echo 'ln -sf /etc/apache2/mods-available/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf'; \
      echo 'ln -sf /etc/apache2/mods-available/mpm_prefork.load /etc/apache2/mods-enabled/mpm_prefork.load'; \
      echo 'cat > /var/www/html/.htaccess << '"'"'HTEOF'"'"''; \
      echo '# BEGIN WordPress'; \
      echo '<IfModule mod_rewrite.c>'; \
      echo 'RewriteEngine On'; \
      echo 'RewriteBase /'; \
      echo 'RewriteRule ^index\.php$ - [L]'; \
      echo 'RewriteCond %{REQUEST_FILENAME} !-f'; \
      echo 'RewriteCond %{REQUEST_FILENAME} !-d'; \
      echo 'RewriteRule . /index.php [L]'; \
      echo '</IfModule>'; \
      echo '# END WordPress'; \
      echo 'HTEOF'; \
      tail -n +2 /usr/local/bin/apache2-foreground; \
    } > /tmp/apache2-foreground \
    && mv /tmp/apache2-foreground /usr/local/bin/apache2-foreground \
    && chmod +x /usr/local/bin/apache2-foreground

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80
