#!/bin/sh

echo "[i] OS: Creating MySQL Sockets/run/pid Directories"
mkdir -p /run/mysqld
mkdir -p /run/nginx

echo "[i] PHP: Fixing cgi.fix_pathinfo"
sed -i 's/;cgi.fix_path/cgi.fix_path/' /etc/php7/php.ini

echo "[i] PHP: Enabling Xdebug"
sed -i 's/;zend_extension/zend_extension/' /etc/php7/conf.d/xdebug.ini


echo "[i] NGINX: Creating www root and a info.php (for testing purposes)"
mkdir -p /app/www/public
echo "<?php phpinfo();" > /app/www/public/info.php

echo "[i] OS: Creating logs directory"
mkdir -p /app/logs

echo "[i] OS: Starting php-fpm"
php-fpm7 -D

if [ -d /app/mysql ]; then
  echo "[i] MySQL: directory already present, skipping creation"
else
  echo "[i] MySQL: Creating initial DBs"
  
  tfile=`mktemp`
  if [ ! -f "$tfile" ]; then
    echo "[E] OS: Unable to create tempfile"
    return 1
  fi

  echo "[i] MySQL: Init installer"
  mysql_install_db --user=root >/dev/null 2>&1

  if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
    MYSQL_ROOT_PASSWORD="123456"
  fi

  MYSQL_DATABASE=${MYSQL_DATABASE:-"app"}
  MYSQL_USER=${MYSQL_USER:-"user"}
  MYSQL_PASSWORD=${MYSQL_PASSWORD:-"123456"}

  
  echo "[i] MySQL: Root Access: only localhost password:"
  echo "    User: root"
  echo "    Password: '$MYSQL_ROOT_PASSWORD'"
  echo "[i] MySQL: User access:"
  echo "    User: '$MYSQL_USER'"
  echo "    Host: % | localhost"
  echo "    Password: '$MYSQL_PASSWORD'"
  echo "    DB-Name: '$MYSQL_DATABASE'"

  cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("") WHERE user='root' AND host='localhost';

CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL ON \`$MYSQL_DATABASE\`.* to '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
FLUSH PRIVILEGES;
EOF

  /usr/bin/mysqld --user=root --bootstrap --verbose=0 >/dev/null 2>&1 < $tfile 
  rm -f $tfile
fi

/usr/bin/mysqld --user=root >/app/mysql/output.log 2>&1 &

exec nginx -g "daemon off;"
