FROM wordpress:php8.2-apache

# Fix MPM conflict at runtime via custom entrypoint
RUN printf '#!/bin/bash\nset -e\nrm -f /etc/apache2/mods-enabled/mpm_event.conf\nrm -f /etc/apache2/mods-enabled/mpm_event.load\nrm -f /etc/apache2/mods-enabled/mpm_worker.conf\nrm -f /etc/apache2/mods-enabled/mpm_worker.load\nexec /usr/local/bin/docker-entrypoint.sh "$@"\n' > /fix-mpm.sh && chmod +x /fix-mpm.sh

COPY wp-content/ /var/www/html/wp-content/

EXPOSE 80

ENTRYPOINT ["/fix-mpm.sh"]
CMD ["apache2-foreground"]
