# Use the supported PHP 8.5 release with Apache on Debian Trixie.
# https://hub.docker.com/_/php
FROM php:8.5-apache-trixie

# Copy local code to the container image.
COPY index.php /var/www/html/

# Default to port 8080 for local runs; Knative supplies PORT when deployed.
ENV PORT=8080

# Use the PORT environment variable in Apache configuration files.
RUN sed -i 's/*:80>/*:${PORT}>/' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's/^Listen 80$/Listen ${PORT}/' /etc/apache2/ports.conf

# Use PHP's production configuration (do not display errors to clients).
# https://hub.docker.com/_/php#configuration
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

