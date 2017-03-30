
icinga_stopped:
  service.dead:
  - name: icinga2

icinga2_packages_purged:
  pkg.purged:
  - pkgs:
    - icinga2
    - nagios-plugins
    - mysql-client
    - mysql-common

icinga2_packages_autopurged:
  cmd.run:
  - name: apt-get autoremove --purge -y --force-yes

icinga2_files:
  cmd.run:
  - name: rm -rf /etc/icinga2 /var/lib/icinga2 /var/log/icinga2 /var/lib/mysql
