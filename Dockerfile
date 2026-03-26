RUN apt-get update && apt-get install -y apache2 && \
    a2dismod mpm_event || true && \
    a2enmod mpm_prefork rewrite headers || true
