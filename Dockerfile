FROM wordpress:php8.2-apache

# Inject MPM cleanup into apache2-foreground so it runs AFTER all volume mounts
# This ensures any runtime-restored mpm_event/worker files are removed last
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

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80
