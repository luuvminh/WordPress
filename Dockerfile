FROM php:8.2-apache

RUN rm -f /etc/apache2/mods-enabled/mpm_event.conf \
           /etc/apache2/mods-enabled/mpm_event.load \
                      /etc/apache2/mods-enabled/mpm_worker.conf \
                                 /etc/apache2/mods-enabled/mpm_worker.load && \
                                     a2enmod mpm_prefork rewrite headers

                                     COPY . /var/www/html/

                                     EXPOSE 80
