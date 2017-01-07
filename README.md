Alpine LEMP
===========

A docker image based on alpine-linux with nginx, mysql and php7.

Inspired by [Alpine MYSQL](https://github.com/wangxian/alpine-mysql)

Build
======

```bash
docker build -t josegomezr/alpine-lemp .
```

It will create a default database `app` and a user `user` with password `123456`. Root access is only allowed for local connections. And the default root password is also `123456`. You can change this defaults by altering the following envs:

```
MYSQL_ROOT_PASSWORD
MYSQL_USER
MYSQL_PASSWORD
MYSQL_DATABASE
```

Running
========

```
docker run -v $(pwd)/app:/app -p 8000:80 -p 3306:3306 -d lemp
```

It'll mount an app dir with the following schema:
```
/
- mysql/
  ... #mysql data directory
- logs/
  - nginx_access.log
  - nginx_error.log
  - php_error.log
- www/
  - public/ # public nginx root
  	  - info.php # a dumb phpinfo();
```