icingaweb_stopped:
  service.dead:
  - name: apache2

icingaweb2_packages_purged:
  pkg.purged:
  - pkgs:
    - apache2
    - icingaweb2
    - icingaweb2-module-monitoring
    - libapache2-mod-php5
    - php5-cli
    - php5-mysql
    - php5-ldap

icingaweb2_packages_autopurged:
  cmd.run:
  - name: apt-get autoremove --purge -y --force-yes

icingaweb2_files:
  cmd.run:
  - name: rm -rf /etc/icingaweb2
