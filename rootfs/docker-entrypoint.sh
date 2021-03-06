#!/bin/sh

## apache user UID & GID change
if [ ! -z ${USER_UID+x} ]; then
	echo "Updating apache uid to $USER_UID..."
	usermod -u $USER_UID apache
fi

if [ ! -z ${USER_GID+x} ]; then
	echo "Updating apache gid to $USER_GID..."
	groupmod -g $USER_GID apache
	chown root:apache /var/lib/php/*
fi

## Set container timezone
TZ="${TZ:-Europe/Prague}"
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

## PHP configucation update
echo "Updating php configuration..."
# Variables to allow adhoc change using docker env
PHP_INI="/etc/php.ini"
PHP_TZ="$TZ"
PHP_POSTMAX="${PHP_POSTMAX:-10M}"
PHP_UPLOADMAX="${PHP_UPLOADMAX:-10M}"
PHP_URLFOPEN="${PHP_URLFOPEN:-On}"
PHP_DISABLE_USERINI="${PHP_DISABLE_USERINI:-1}"
PHP_EXECMAX="${PHP_EXECMAX:-15}"
PHP_INPUTMAX="${PHP_INPUTMAX:-60}"
PHP_MEMLIMIT="${PHP_MEMLIMIT:-96M}"
# Fix TZ for sed replacement
PHP_TZ="$(echo $PHP_TZ | sed 's/\//\\\//')"
sed -i -e "s/\(;\)\?\(date.timezone\s\?=\)\(.*\)\?/\2 $PHP_TZ/" $PHP_INI
sed -i -e "s/\(post_max_size\s\?=\s\?\).*/\1$PHP_POSTMAX/" $PHP_INI
sed -i -e "s/\(upload_max_filesize\s\?=\s\?\).*/\1$PHP_UPLOADMAX/" $PHP_INI
sed -i -e "s/\(allow_url_fopen\s\?=\s\?\).*/\1$PHP_URLFOPEN/" $PHP_INI
sed -i -e "s/\(max_execution_time\s\?=\s\?\).*/\1$PHP_EXECMAX/" $PHP_INI
sed -i -e "s/\(max_input_time\s\?=\s\?\).*/\1$PHP_INPUTMAX/" $PHP_INI
sed -i -e "s/\(memory_limit\s\?=\s\?\).*/\1$PHP_MEMLIMIT/" $PHP_INI
sed -i -e "s/^\(error_reporting\s\?=\s\?\).*/\1E_ALL \& ~E_DEPRECATED \& ~E_STRICT \& ~E_NOTICE/" $PHP_INI
sed -i -e "s/\(;\)\?\(error_log\s\?=\)\(.*\)\?/\2 \/dev\/stderr/" $PHP_INI
if [ "$PHP_DISABLE_USERINI" = "1" ]; then
	sed -i -e "s/\(;\)\?\(user_ini.filename\s\?=\)$/\2/" $PHP_INI
fi
# Set apache module limits
cat <<EOF > /etc/httpd/conf.d/php_limit.conf
php_admin_value post_max_size $PHP_POSTMAX
php_admin_value upload_max_filesize $PHP_UPLOADMAX
php_admin_value max_execution_time $PHP_EXECMAX
php_admin_value max_input_time $PHP_INPUTMAX
php_admin_value memory_limit $PHP_MEMLIMIT
php_admin_flag allow_url_fopen $PHP_URLFOPEN
EOF

# Zend OPcache
OPCACHE_MEM="${OPCACHE_MEM:-64}"
OPCACHE_INI="/etc/php.d/10-opcache.ini"
sed -i -e "s/\(opcache\.memory_consumption\s\?=\s\?\).*/\1$OPCACHE_MEM/" $OPCACHE_INI

# Set apache as owner/group
if [ "$(stat -c "%U-%G" /var/www/html)" != "apache-apache" ]; then
	echo "Fixing webroot ownership..."
        chown -R apache:apache /var/www/html
fi

echo "Entrypoint script finished!"

exec "$@"
