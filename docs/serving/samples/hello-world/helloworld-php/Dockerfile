# Use the official PHP image
# https://hub.docker.com/_/php
FROM php:cli-alpine

COPY index.php /
EXPOSE 80

# Use PHP built-in web server for serving index.php
# https://www.php.net/manual/en/features.commandline.webserver.php
ENTRYPOINT ["php", "-S", "0.0.0.0:80", "/index.php"]
