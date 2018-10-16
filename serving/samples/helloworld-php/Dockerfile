FROM php:7.2.6-apache

COPY index.php /var/www/html/

ENV PORT 8080

RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
