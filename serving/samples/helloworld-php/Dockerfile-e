FROM php:7.2.6-apache

COPY index.php /var/www/html/

# Run on port 8080 rather than 80
RUN sed -i 's/80/8080/g' /etc/apache2/sites-available/000-default.conf /etc/apache2/ports.conf
