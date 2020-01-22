FROM centos:7

MAINTAINER marek.haluska@gmail.com

ARG PHPVER=5.4

RUN set -x && \
    yum -y install epel-release && \
    yum -y install \
      httpd \
      php \
      php-bcmath \
      php-dba \
      php-gd \
      php-intl \
      php-ldap \
      php-mbstring \
      php-mysqlnd \
      php-odbc \
      php-pdo \
      php-pear \
      php-pgsql \
      php-process \
      php-pspell \
      php-recode \
      php-soap \
      php-xml \
      php-xmlrpc \
      ghostscript \
      php-pecl-zendopcache \
      php-pclzip \
    && \
    rm -f /etc/httpd/conf.d/userdir.conf /etc/httpd/conf.d/welcome.conf && \
    rm -f /etc/httpd/conf.modules.d/00-proxy.conf /etc/httpd/conf.modules.d/00-systemd.conf && \
    yum clean all && rm -rf /var/log/* && rm -rf /var/lib/yum/* && rm -rf /var/cache/yum/*

COPY rootfs/ /

EXPOSE 80

WORKDIR /var/www/html

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
