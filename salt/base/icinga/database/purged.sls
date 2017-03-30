
mysql_packages_purged:
  pkg.purged:
  - pkgs:
    - mysql-server
    - mysql-client
    - mysql-common

mysql_packages_autopurged:
  cmd.run:
  - name: apt-get autoremove --purge -y --force-yes

mysql_files:
  cmd.run:
  - name: rm -rf /var/lib/mysql /etc/mysql/conf.d/icingadb.cnf
