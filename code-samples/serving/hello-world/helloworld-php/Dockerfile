# Use the official PHP 7.3 image.
# https://hub.docker.com/_/php
FROM php:7.3-apache

ARG USER=appuser
ARG USER_UID=1001
ARG USER_GID=$USER_UID

ENV PORT=8080

# Add a user so the server will run as a non-root user.
RUN addgroup --gid $USER_GID $USER && \
    adduser -u $USER_UID --ingroup $USER --disabled-password $USER

# Copy local code to the container image.
COPY index.php /var/www/html/

# Use the PORT environment variable in Apache configuration files.
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf

RUN chown $USER: $PHP_INI_DIR

# Set the non-root user as current.
USER $USER

# Configure PHP for development.
# Switch to the production php.ini for production operations.
# RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
# https://hub.docker.com/_/php#configuration
RUN mv "${PHP_INI_DIR}/php.ini-development" "${PHP_INI_DIR}/php.ini"
