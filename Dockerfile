FROM wordpress:latest

# Force-disable the 'event' MPM and enable 'prefork' (which WordPress needs)
RUN a2dismod mpm_event || true && a2enmod mpm_prefork

# Clear the PID file to prevent start-up crashes
RUN rm -f /var/run/apache2/apache2.pid

# Standardize the port
EXPOSE 80
