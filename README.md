# Docker image based on CentOS with Apache2 and PHP

CentOS image version: centos:7

Source: [https://github.com/mhaluska/docker-centos-php](https://github.com/mhaluska/docker-centos-php)

### Following environment variables can be used to customize this image

#### Change apache user UID and GID if defined:
- USER_UID=123
- USER_GID=321

#### PHP modification
- PHP_TZ (date.timezone, default Europe/Prague)
- PHP_POSTMAX (post_max_size, default 10M)
- PHP_UPLOADMAX (upload_max_filesize, default 10M)
- PHP_URLFOPEN (allow_url_fopen, default On)
- PHP_DISABLE_USERINI (user_ini.filename, default 1 = disable this func)
- PHP_EXECMAX (max_execution_time, default 15)
- PHP_INPUTMAX (max_input_time, default 60)
- PHP_MEMLIMIT (memory_limit, default 96M)

#### Zend OPcache
- OPCACHE_MEM (opcache.memory_consumption, default 64)
