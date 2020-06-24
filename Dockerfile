FROM centos:8

MAINTAINER marek.haluska@gmail.com

ARG PHPVER=7.3

RUN set -x && \
    dnf -y module enable php:${PHPVER} && \
    dnf -y install --exclude=nginx-filesystem --exclude=php-fpm \
      httpd \
      php \
      php-bcmath \
      php-dba \
      php-gd \
      php-gmp \
      php-intl \
      php-json \
      php-ldap \
      php-mbstring \
      php-mysqlnd \
      php-odbc \
      php-opcache \
      php-pdo \
      php-pear \
      php-pgsql \
      php-process \
      php-recode \
      php-soap \
      php-xml \
      php-xmlrpc \
      ghostscript \
    && \
    rm -f /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/welcome.conf && \
    rm -f /etc/httpd/conf.modules.d/10-h2.conf /etc/httpd/conf.modules.d/10-proxy_h2.conf \
      /etc/httpd/conf.modules.d/00-proxy.conf /etc/httpd/conf.modules.d/00-systemd.conf && \
    dnf clean all && rm -rf /var/log/* && rm -rf /var/lib/dnf/* && rm -rf /var/cache/dnf/*

COPY rootfs/ /

EXPOSE 80

WORKDIR /var/www/html

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
