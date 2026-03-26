RUN a2dismod mpm_event mpm_worker && \
    a2enmod mpm_prefork
