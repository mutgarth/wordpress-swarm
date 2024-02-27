FROM wordpress:latest

RUN apt-get update && apt-get install nano

RUN chown -R www-data:www-data /var/www/html
