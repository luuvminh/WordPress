FROM wordpress:php8.2-apache

# Build-time: remove ALL mpm modules, enable only prefork
RUN rm -f /etc/apache2/mods-enabled/mpm_*.conf \
          /etc/apache2/mods-enabled/mpm_*.load \
    && a2enmod mpm_prefork || true

# Runtime wrapper: print mods-enabled at startup, re-clean, then start WordPress
RUN printf '#!/bin/bash\necho "=== RUNTIME mods-enabled (mpm) ==="\nls /etc/apache2/mods-enabled/ | grep mpm || echo "(none)"\nrm -f /etc/apache2/mods-enabled/mpm_event.conf /etc/apache2/mods-enabled/mpm_event.load\nrm -f /etc/apache2/mods-enabled/mpm_worker.conf /etc/apache2/mods-enabled/mpm_worker.load\necho "=== After cleanup ==="\nls /etc/apache2/mods-enabled/ | grep mpm || echo "(none)"\nexec /usr/local/bin/docker-entrypoint.sh "\$@"\n' > /runtime-fix.sh && chmod +x /runtime-fix.sh

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80

ENTRYPOINT ["/runtime-fix.sh"]
CMD ["apache2-foreground"]
