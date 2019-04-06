FROM php:5.6-apache

MAINTAINER Odenktools <odenktools86@gmail.com>

ENV TZ=Asia/Jakarta

USER root

RUN echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && echo date.timezone = $TZ > /usr/local/etc/php/conf.d/docker-php-ext-timezone.ini

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends apt-utils && \
    pecl channel-update pecl.php.net

RUN apt-get update -yqq \
    && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    unzip \
    pkg-config \
    libz-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libxml2-dev \
    zlib1g-dev libicu-dev \
    apache2-utils \
    libcurl4-openssl-dev \
    libssl-dev \
    libkrb5-dev \
    libmcrypt-dev \
    unixodbc-dev \
    libssh2-1-dev \
    libpq-dev \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

# Install the PHP gd library
RUN docker-php-ext-install gd && \
    docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-jpeg-dir=/usr/lib \
        --with-freetype-dir=/usr/include/freetype2 && \
    docker-php-ext-install gd

RUN pecl install xdebug-2.5.5 \
    && docker-php-ext-enable xdebug

RUN docker-php-ext-install pdo \
    && docker-php-ext-install mcrypt \
    && docker-php-ext-install mbstring \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-install mysql mysqli \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd \
    && docker-php-ext-configure mysqli --with-mysqli=mysqlnd \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-install pdo_pgsql pgsql \
    && docker-php-ext-install zip \
    && docker-php-ext-install json \
    && docker-php-ext-install soap \
    && docker-php-ext-install xml \
    && docker-php-ext-install bcmath \
    && pecl install mongo \
    && pecl install -a ssh2-0.13 && docker-php-ext-enable ssh2\
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

RUN apt-get update -yqq && apt-get install -y libgmp-dev libgmp3-dev && \
    ln -s /usr/include/x86_64-linux-gnu/gmp.h /usr/include/gmp.h && \ 
    docker-php-ext-install gmp

###########################################################################
# YAML:
###########################################################################
RUN apt-get update -yqq && apt-get install libyaml-dev -y && \
    pecl install yaml-1.3.0 ; \
    docker-php-ext-enable yaml \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

RUN { \
    echo 'always_populate_raw_post_data=-1'; \
    echo 'log_errors=on'; \
    echo 'display_errors=on'; \
    echo 'upload_max_filesize=32M'; \
    echo 'post_max_size=32M'; \
    echo 'memory_limit=512M'; \
    echo 'date.timezone=$TZ'; \
  } > /usr/local/etc/php/php.ini

RUN docker-php-ext-enable intl \
    && docker-php-ext-enable gd \
    && docker-php-ext-enable mcrypt \
    && docker-php-ext-enable mbstring \
    && docker-php-ext-enable mysql \
    && docker-php-ext-enable mysqli \
    && docker-php-ext-enable pdo_mysql \
    && docker-php-ext-enable pdo_pgsql \
    && docker-php-ext-enable pgsql \
    && docker-php-ext-enable mysqli \
    && docker-php-ext-enable zip \
    && docker-php-ext-enable soap \
    && docker-php-ext-enable json \
    && docker-php-ext-enable xml \
    && docker-php-ext-enable mongo \
    && docker-php-ext-enable bcmath

###########################################################################
# Check PHP version:
###########################################################################

RUN php -v | head -n 1 | grep -q "PHP 5.6."

RUN curl -sSL https://getcomposer.org/download/1.7.3/composer.phar -o /usr/bin/composer \
    && chmod +x /usr/bin/composer \
    && composer selfupdate

RUN mkdir -p /var/www/html && mkdir -p /etc/apache2/ssl

COPY index.html /var/www/html

COPY config/apache2/apache2.conf /etc/apache2/apache2.conf

RUN { \
    echo '<VirtualHost *:80>';\
    	echo 'ServerAdmin odenktools@gmail.com';\
    	echo 'DocumentRoot /var/www/html';\
    	echo 'ErrorLog ${APACHE_LOG_DIR}/error.log';\
    	echo 'CustomLog ${APACHE_LOG_DIR}/access.log combined';\
    echo '</VirtualHost>';\
} > /etc/apache2/sites-available/000-default.conf

#RUN sed -i "s/DocumentRoot \/var\/www\/html/DocumentRoot \/var\/www/html/" /etc/apache2/apache2.conf

RUN usermod -u 1000 www-data

RUN chown -R www-data:www-data /var/www/

RUN chmod -R 777 /var/www/

RUN a2enmod rewrite proxy expires headers && service apache2 restart

VOLUME ["/var/www/html", "/var/log/apache2", "/etc/apache2/sites-available"]

WORKDIR /var/www/html

EXPOSE 80 443

CMD ["apache2-foreground"]

#eof