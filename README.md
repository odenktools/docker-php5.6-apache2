# Docker PHP Apache2

Simple Docker PHP 5.6 + Apache/2.4.25 container.

## Inside Container

* php5.6.x
* Apache/2.4.25
* Git
* bash

## PHP Modules

* php5.6-gd
* php5.6-mcrypt
* php5.6-mbstring
* php5.6-intl
* php5.6-mysql
* php5.6-zip
* php5.6-json
* php5.6-soap
* php5.6-xml
* php5.6-bcmath
* php5.6-mysqli
* xdebug-2.5.5


## How to use

```bash
docker pull odenktools/php5.6-apache2:latest
```

``Create docker network``

```bash
docker network create odenktools-net
```

``Run a container.``

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
-d odenktools/php5.6-apache2:latest
```

``Linking other container.``

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
--link mysql:mysql \
-d odenktools/php5.6-apache2:latest
```

``Linking another container + mount existing code.``

``For Windows OS``

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
--link mysql:mysql \
--mount type=bind,source=/d/git/php-script,target=/var/www \
-d odenktools/php5.6-apache2:latest
```

``For Linux OS``

```bash
docker run -d --name php_sample \
--net=odenktools-net \
--publish 80:80 \
--link mysql:mysql \
--mount type=bind,source=/var/www/php-script,target=/var/www \
-d odenktools/php5.6-apache2:latest
```

## Running Laravel 5.2 Inside Container

**First you must create apache virtualhost**

```bash
cat <<EOF > $(pwd)/config/000-default.conf
<VirtualHost *:80>
    ServerAdmin odenktools@gmail.com
    DocumentRoot /var/www/html/public
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF
```

**Then run a container**

```
docker run -d --name laravel \
--net=odenktools-net \
--link mysql:mysql \
--publish 80:80 \
-v ./config:/etc/apache2/sites-available \
--mount type=bind,source=/var/www/laravel.5-2,target=/var/www/html \
odenktools/docker-php-apache2:latest
```

``OR using docker compose``

``For Windows OS``

```
version: "3.6"

services:

  laraveldb:
    image: percona:5.6
    container_name: laraveldb
    restart: on-failure
    environment:
      - MYSQL_ROOT_PASSWORD=odenktools
      - MYSQL_PASSWORD=odenktools
      - MYSQL_DATABASE=laravel_db
    ports:
      - "33062:3306"
    networks: ['default']

  laravel:
    container_name: laravel
    image: odenktools/php5.6-apache2:latest
    networks: ['default']
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/d/git/config/apache2/laravel:/etc/apache2/sites-available" # Your apache 000-default.conf directory location
      - "/d/htdocs/laravel:/var/www/html"
    depends_on:
      - laraveldb

networks:
  default:
    external:
      name: odenktools-net
```

``For Linux OS``

```
version: "3.6"

services:

  laraveldb:
    image: percona:5.6
    container_name: laraveldb
    restart: on-failure
    environment:
      - MYSQL_ROOT_PASSWORD=odenktools
      - MYSQL_PASSWORD=odenktools
      - MYSQL_DATABASE=laravel_db
    ports:
      - "33062:3306"
    networks: ['default']

  laravel:
    container_name: laravel
    image: odenktools/php5.6-apache2:latest
    networks: ['default']
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/opt/apache2/laravel:/etc/apache2/sites-available" # Your apache 000-default.conf directory location
      - "/var/www/laravel:/var/www/html"
    depends_on:
      - laraveldb

networks:
  default:
    external:
      name: odenktools-net
```

## Build Container

```bash
docker build --no-cache --compress --tag odenktools/php5.6-apache2:1.0.0 .

docker tag odenktools/php5.6-apache2:1.0.0 odenktools/php5.6-apache2:latest

docker push odenktools/php5.6-apache2:1.0.0

docker push odenktools/php5.6-apache2:latest
```