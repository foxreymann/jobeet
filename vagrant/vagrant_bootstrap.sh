#!/bin/bash
(
  export DEBIAN_FRONTEND=noninteractive

  hostname test.flooved.com

  echo "### Fixing dns entries"
  sed -i -e"s/domain-name-servers, //g" /etc/dhcp/dhclient.conf
  if [ -z `grep -Fl 8.8.8.8 /etc/dhcp/dhclient.conf` ]; then
    echo >>/etc/dhcp/dhclient.conf
    echo "prepend domain-name-servers 8.8.8.8,8.8.4.4;" >>/etc/dhcp/dhclient.conf
  fi
  (dhclient -r && dhclient eth0)

  echo "### Adding PHP 5.4 repo"
  apt-get update
  apt-get -y install python-software-properties
  add-apt-repository -y ppa:ondrej/php5

  echo "### Updating apt data"
  apt-get update

  echo "### Installing necessary packages"
  apt-get -y install htop
  apt-get -y install git
  apt-get -y install apache2
  apt-get -y install apache2-mpm-prefork
  apt-get -y install libapache2-mod-php5
  apt-get -y install php5-mysqlnd
  apt-get -y install php5-curl
  apt-get -y install php5-intl
  apt-get -y install php-apc
  apt-get -y install php-pear
  apt-get -y install php5-curl
  apt-get -y install php5-mcrypt
  apt-get -y install liboauth-php
  apt-get -q -y install mysql-server-5.5
  apt-get -q -y install postfix
  apt-get -y install memcached
  apt-get -y install libmemcached10
  apt-get -y install php5-memcached
  
  echo "### Update system time"
  ntpdate ntp.ubuntu.com

  if [ ! `which pdf2htmlEX` ]; then
    echo "### Installing pdf2htmlEX 0.8.1 using downloaded packages"
    wget https://s3-eu-west-1.amazonaws.com/flooved-v2-ubuntu-repo/libfontconfig1_2.10.1-0ubuntu3_amd64.deb
    wget https://s3-eu-west-1.amazonaws.com/flooved-v2-ubuntu-repo/fontconfig-config_2.10.1-0ubuntu3_all.deb
    wget https://s3-eu-west-1.amazonaws.com/flooved-v2-ubuntu-repo/liblzma5_5.1.1alpha~20120614-1_amd64.deb
    wget https://s3-eu-west-1.amazonaws.com/flooved-v2-ubuntu-repo/libjbig0_2.0-2ubuntu1_amd64.deb
    wget https://s3-eu-west-1.amazonaws.com/flooved-v2-ubuntu-repo/liblcms2-2_2.2~git20110628-2ubuntu3_amd64.deb
    wget https://s3-eu-west-1.amazonaws.com/flooved-v2-ubuntu-repo/libtiff5_4.0.2-1ubuntu2.1_amd64.deb
    wget https://s3-eu-west-1.amazonaws.com/flooved-v2-ubuntu-repo/libpoppler28_0.20.4-0ubuntu1.2_amd64.deb
    wget https://s3-eu-west-1.amazonaws.com/flooved-v2-ubuntu-repo/pdf2htmlex_0.8-1~git201303011406r3bc73-0ubuntu1_amd64.deb

    apt-get -y install libjpeg8
    apt-get -y install libfontforge1
    apt-get -y install ttf-dejavu-core ttf-bitstream-vera ttf-freefont gsfonts-x11

    dpkg -i fontconfig-config_2.10.1-0ubuntu3_all.deb
    dpkg -i libfontconfig1_2.10.1-0ubuntu3_amd64.deb
    dpkg -i liblzma5_5.1.1alpha~20120614-1_amd64.deb
    dpkg -i libjbig0_2.0-2ubuntu1_amd64.deb
    dpkg -i liblcms2-2_2.2~git20110628-2ubuntu3_amd64.deb
    dpkg -i libtiff5_4.0.2-1ubuntu2.1_amd64.deb
    dpkg -i libpoppler28_0.20.4-0ubuntu1.2_amd64.deb
    dpkg -i pdf2htmlex_0.8-1~git201303011406r3bc73-0ubuntu1_amd64.deb
  fi

  echo "### installing php unit"
  pear upgrade pear
  pear channel-discover pear.phpunit.de
  pear channel-discover components.ez.no
  pear channel-discover pear.symfony.com
  pear install --alldeps phpunit/PHPUnit

  echo "### configuring postfix"
  sed -i -e"s/inet_interfaces = all/inet_interfaces = 127.0.0.1/g" /etc/postfix/main.cf
  service postfix restart

  echo "### Configure MySql for remote connections"
  sed -i -e"s/127.0.0.1/0.0.0.0/g" /etc/mysql/my.cnf
  mysql -uroot -e"GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;"

  echo "### Installing dependencies"
  cd /srv/www/v2/
  php composer.phar install

  echo "### PHP settings"
  PHP_SETTINGS='
    display_errors=on
    open_basedir=none
    upload_max_filesize=50M
    post_max_size=50M
    max_execution_time=0
    date.timezone="Europe/London"
  '
  echo "${PHP_SETTINGS}" >/etc/php5/conf.d/90-flooved.ini

  echo "### Configuring Apache"
  APACHE_CONFIG='
  <VirtualHost *:80>
    DocumentRoot "/srv/www/v2/web"
    ServerName flooved.v2
    SetEnv APPLICATION_ENV "development"
    #ErrorLog "/srv/www/v2/data/logs/error_log"
    #CustomLog "/srv/www/v2/data/logs/access_log" common
    <Directory /srv/www/v2/web>
      AllowOverride All
      Options Indexes FollowSymLinks
      Order allow,deny
      Allow from all
    </Directory>
  </VirtualHost>
  '
  echo "${APACHE_CONFIG}" >/etc/apache2/sites-enabled/000-default
  a2enmod rewrite
  service apache2 restart

)2>&1 | logger -t vagrant.bootstrap
exit 0

