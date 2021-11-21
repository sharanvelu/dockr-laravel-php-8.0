FROM php:8.0-apache-buster

LABEL Author="Sharan" "org.opencontainers.image.authors"="Sharan" Description="Image used for Dockr Coantiners." "com.example.vendor"="DockR.in" website="dockr.in"

RUN apt-get update && \
    apt-get install -y \
        git \
        libfreetype6-dev \
        libldap2-dev \
        libgmp-dev \
        libmcrypt-dev \
        libonig-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
        netcat \
        npm \
        procps \
        supervisor \
        vim \
        yarn \
        zip \
        zlib1g-dev

RUN docker-php-ext-install bcmath exif gd gmp ldap mbstring mysqli pcntl pdo pdo_mysql sysvmsg zip

# xDebug
RUN pecl install xdebug
COPY php/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# Php Conf
RUN echo 'memory_limit = 512M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini \
    && echo "upload_max_filesize = 1000M;" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 1000M;" >> /usr/local/etc/php/conf.d/max_size.ini

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer --version=2.1.3

WORKDIR /var/www/html

RUN chmod -R 777 /var/www/html \
    && mkdir public

COPY apache/000-default.conf /etc/apache2/sites-available/000-default.conf

#supervisor config
COPY supervisor/supervisor.conf /etc/supervisor/supervisord.conf
COPY supervisor/supervisor.conf /etc/supervisord.conf
COPY supervisor /etc/supervisor/disabled

ENV DOCKR_SERVER_TYPE="apache"

COPY entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

RUN a2enmod rewrite \
    && rm -rf public \
    && apt-get clean
