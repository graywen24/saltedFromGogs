
# set a root password for mysql before installation - to prevend passwordless installation
mysql_debconf:
  debconf.set:
  - name: mysql-server-5.5
  - data:
      'mysql-server/root_password': {'type': 'password', 'value': '{{ pillar.mysql.adminpass }}' }
      'mysql-server/root_password_again': {'type': 'password', 'value': '{{ pillar.mysql.adminpass }}' }
  - unless: dpkg --get-selections | grep -q mysql-server

# install packages
mysql_server_packages:
  pkg.latest:
  - pkgs:
    - python-mysqldb
    - mysql-server
  - require:
    - debconf: mysql_debconf

# drop the password in case installation did not do it
mysql_debconf_drop:
  debconf.set:
  - name: mysql-server-5.5
  - data:
      'mysql-server/root_password': {'type': 'password', 'value': ''}
      'mysql-server/root_password_again': {'type': 'password', 'value': ''}
  - onlyif: dpkg --get-selections | grep -q mysql-server
  - require:
    - pkg: mysql_server_packages
